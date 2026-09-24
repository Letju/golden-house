#!/usr/bin/env python3
"""Genere le MCD du rapport depuis la BDD PostgreSQL (source de verite).

Usage : PGHOST=.. PGPORT=.. PGUSER=.. PGPASSWORD=.. PGDATABASE=.. python3 gen_mcd.py
Sorties : figures/mcd.dot, figures/mcd.pdf (via Graphviz `dot`).
Relancer apres chaque evolution du DDL : le diagramme suit le schema reel.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

DOMAINS = {
    "Utilisateurs": {"color": "#195FD7", "edge": "#1B4FA0",
                     "tables": ["users", "addresses"]},
    "Achats": {"color": "#7D2D96", "edge": "#5E2170",
               "tables": ["orders", "order_items", "invoices",
                          "product_returns", "carts", "cart_items"]},
    "Catalogue": {"color": "#148246", "edge": "#0E5C31",
                  "tables": ["products", "fournisseurs", "supply_orders",
                             "supply_order_items"]},
    "Interactions": {"color": "#0C7378", "edge": "#093F43",
                     "tables": ["reviews", "notifications"]},
}
TABLE_DOMAIN = {t: (name, d["color"], d["edge"])
                for name, d in DOMAINS.items() for t in d["tables"]}

# Colonnes d'audit exclues du diagramme (bruit visuel, présentes dans le DDL)
EXCLUDE_COLS = {"created_at", "updated_at"}

# Découpage du MCD en figures lisibles (une page portrait ne tient pas
# 14 tables à taille lisible). Les tables hors périmètre sont rendues
# en mini-rappels gris pour conserver toutes les relations.
FIGURES = {
    "mcd_achats": ["users", "addresses", "orders", "order_items",
                   "invoices", "product_returns", "carts", "cart_items"],
    "mcd_catalogue": ["products", "fournisseurs", "supply_orders",
                      "supply_order_items", "reviews", "notifications"],
}

TYPE_SHORT = {
    "character varying": "varchar",
    "timestamp with time zone": "timestamptz",
}


def q(sql):
    env = dict(os.environ)
    out = subprocess.run(
        ["psql", "-t", "-A", "-F", "\t", "-c", sql],
        capture_output=True, text=True, env=env, check=True)
    return [line.split("\t") for line in out.stdout.strip().split("\n")
            if line.strip()]


def short_type(data_type, udt_name):
    if data_type == "ARRAY":
        return udt_name.lstrip("_") + "[]"
    if data_type == "USER-DEFINED":
        return udt_name
    return TYPE_SHORT.get(data_type, data_type)


def main():
    tables = [r[0] for r in q(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema='public' AND table_type='BASE TABLE' "
        "ORDER BY table_name")]
    cols = q(
        "SELECT table_name, column_name, data_type, udt_name "
        "FROM information_schema.columns "
        "WHERE table_schema='public' ORDER BY table_name, ordinal_position")
    pks = {r[0]: set(r[1].split(",")) for r in q(
        "SELECT c.table_name, string_agg(k.column_name, ',' ORDER BY k.ordinal_position) "
        "FROM information_schema.table_constraints c "
        "JOIN information_schema.key_column_usage k USING "
        "(constraint_name, table_schema) "
        "WHERE c.table_schema='public' AND c.constraint_type='PRIMARY KEY' "
        "GROUP BY c.table_name")}
    fks = q(
        "SELECT c.table_name, k.column_name, r.table_name "
        "FROM information_schema.table_constraints c "
        "JOIN information_schema.key_column_usage k USING "
        "(constraint_name, table_schema) "
        "JOIN information_schema.constraint_column_usage r USING "
        "(constraint_name, table_schema) "
        "WHERE c.table_schema='public' AND c.constraint_type='FOREIGN KEY'")
    uk_rows = q(
        "SELECT table_name, column_name FROM ("
        "SELECT c.table_name, k.column_name, "
        "count(*) OVER (PARTITION BY c.constraint_name) AS n "
        "FROM information_schema.table_constraints c "
        "JOIN information_schema.key_column_usage k USING "
        "(constraint_name, table_schema) "
        "WHERE c.table_schema='public' AND c.constraint_type='UNIQUE'"
        ") s WHERE n = 1")  # uniques mono-colonne uniquement
    uks = {}
    for t, c in uk_rows:
        uks.setdefault(t, set()).add(c)

    fk_cols = {}
    all_edges = []
    for child, col, parent in fks:
        fk_cols.setdefault(child, set()).add(col)
        if (child, parent) not in [(e[0], e[1]) for e in all_edges]:
            all_edges.append((child, parent))

    for fig_name, fig_tables in list(FIGURES.items()) + [("mcd", tables)]:
        wanted = set(fig_tables)
        # Mini-rappels : uniquement les tables parentes referencees par le
        # perimetre (pas les enfants externes : leurs aretes sont ignorees)
        stubs = sorted({p for c, p in all_edges
                        if c in wanted and p not in wanted})
        lines = ["digraph mcd {",
                 '  rankdir=TB; nodesep=0.45; ranksep=0.75; splines=spline;',
                 '  node [shape=plaintext, fontname="Helvetica", fontsize=11];',
                 '  edge [arrowhead=vee, arrowsize=0.9, penwidth=1.4];', ""]
        for t in tables:
            if t not in wanted and t not in stubs:
                continue
            if t in stubs:  # mini-rappel gris, sans colonnes
                lines.append(
                    f'  {t} [label=<<TABLE BORDER="1" CELLBORDER="0" '
                    f'CELLSPACING="0" CELLPADDING="4">'
                    f'<TR><TD BGCOLOR="#BBBBBB">'
                    f'<FONT COLOR="white"><B>{t}</B></FONT>'
                    f'</TD></TR></TABLE>>];')
                continue
            domain, color, edge = TABLE_DOMAIN[t]
            rows = []
            for tbl, col, dtype, udt in cols:
                if tbl != t or col in EXCLUDE_COLS:
                    continue
                rows.append(
                    f'<TR><TD ALIGN="LEFT"><B>{col}</B></TD>'
                    f'<TD ALIGN="LEFT"><FONT COLOR="#555555">'
                    f'{short_type(dtype, udt)}</FONT></TD></TR>')
            body = "".join(rows)
            lines.append(
                f'  {t} [label=<<TABLE BORDER="1" CELLBORDER="0" '
                f'CELLSPACING="0" CELLPADDING="3">'
                f'<TR><TD BGCOLOR="{color}" COLSPAN="2">'
                f'<FONT COLOR="white"><B>{t}</B></FONT></TD></TR>'
                f'{body}</TABLE>>];')
        lines.append("")
        nedges = 0
        for child, parent in sorted(all_edges):
            if child not in wanted:
                continue
            if parent not in wanted and parent not in stubs:
                continue
            _, _, ecolor = TABLE_DOMAIN[child]
            lines.append(f'  {child} -> {parent} [color="{ecolor}"];')
            nedges += 1
        lines.append("}")
        dot = "\n".join(lines) + "\n"

        dot_path = os.path.join(HERE, fig_name + ".dot")
        pdf_path = os.path.join(HERE, fig_name + ".pdf")
        with open(dot_path, "w") as f:
            f.write(dot)
        subprocess.run(["dot", "-Tpdf", dot_path, "-o", pdf_path], check=True)
        print(f"OK : {fig_name}.pdf "
              f"({len([t for t in tables if t in wanted])} tables"
              f" + {len(stubs)} rappels, {nedges} relations)")


if __name__ == "__main__":
    sys.exit(main())
