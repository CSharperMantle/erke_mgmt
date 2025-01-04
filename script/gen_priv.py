import argparse
import csv

SELECT_TEMPLATES: dict[str, str] = {
    "表": "GRANT SELECT ON TABLE {obj} TO {roles};",
    "视图": "GRANT SELECT ON {obj} TO {roles};",
    "存储过程": "GRANT EXECUTE ON PROCEDURE {obj} TO {roles};",
    "函数": "GRANT EXECUTE ON FUNCTION {obj} TO {roles};",
}
SELECT_EMPTY_TEMPLATE = "-- No SELECT/EXECUTE specified for {obj}"
INSERT_TEMPLATES: dict[str, str] = {
    "表": "GRANT INSERT ON TABLE {obj} TO {roles};",
}
INSERT_EMPTY_TEMPLATE = "-- No INSERT specified for {obj}"
UPDATE_TEMPLATES: dict[str, str] = {
    "表": "GRANT UPDATE ON TABLE {obj} TO {roles};",
}
UPDATE_EMPTY_TEMPLATE = "-- No UPDATE specified for {obj}"
DELETE_TEMPLATES: dict[str, str] = {
    "表": "GRANT DELETE ON TABLE {obj} TO {roles};",
}
DELETE_EMPTY_TEMPLATE = "-- No DELETE specified for {obj}"

FILE_TYPES = ("s", "i", "u", "d")
OBJ_TYPES = ("表", "视图", "存储过程", "函数")
YES_VALUES = ("Y", "C")
NO_VALUES = ("N", "#N/A")


def get_roles(row: dict[str, str]) -> list[str]:
    roles = []
    if row["学生"] in YES_VALUES:
        roles.append("erke_student")
    if row["组织者"] in YES_VALUES:
        roles.append("erke_organizer")
    if row["审核员"] in YES_VALUES:
        roles.append("erke_auditor")
    return roles


def get_sql(template: dict[str, str], row: dict[str, str], empty_template: str) -> str:
    roles = get_roles(row)
    if len(roles) == 0:
        return empty_template.format(obj=row["名称"])
    return template[row["类别"]].format(
        obj=row["名称"], roles=", ".join(roles)
    )


parser = argparse.ArgumentParser()
parser.add_argument(
    "-i", "--input", dest="input", required=True, help="Input CSV file path"
)
parser.add_argument(
    "-o", "--output", dest="output", required=True, help="Output SQL file path"
)
parser.add_argument(
    "-t",
    "--type",
    dest="type",
    choices=FILE_TYPES,
    default="s",
    help="Type of privilege to grant",
)

args = parser.parse_args()

output: list[str] = []
with open(args.input, "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    assert args.type in FILE_TYPES
    if args.type == "s":
        for row in reader:
            if row["类别"] not in OBJ_TYPES:
                continue
            roles = get_roles(row)
            output.append(get_sql(SELECT_TEMPLATES, row, SELECT_EMPTY_TEMPLATE))
    elif args.type == "i":
        for row in reader:
            if row["类别"] != "表":
                continue
            roles = get_roles(row)
            output.append(get_sql(INSERT_TEMPLATES, row, INSERT_EMPTY_TEMPLATE))
        pass
    elif args.type == "u":
        for row in reader:
            if row["类别"] != "表":
                continue
            roles = get_roles(row)
            output.append(get_sql(UPDATE_TEMPLATES, row, UPDATE_EMPTY_TEMPLATE))
    elif args.type == "d":
        for row in reader:
            if row["类别"] != "表":
                continue
            roles = get_roles(row)
            output.append(get_sql(DELETE_TEMPLATES, row, DELETE_EMPTY_TEMPLATE))
    else:
        raise ValueError("Invalid type", args.type)

if args.output == "-":
    print("\n".join(output))
else:
    with open(args.output, "w", encoding="utf-8") as f:
        f.write("\n".join(output))
        f.write("\n")
