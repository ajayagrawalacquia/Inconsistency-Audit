import sys

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 find_inconsistency.py file_path")
        return

    file_path = sys.argv[1]

    server_types = {}
    ami_types = {}

    with open(file_path, "r") as file:
        for line in file:
            parts = line.strip().split()
            if len(parts) == 2:
                server_name, ami_type = parts
                server_type = server_name.split("-")[0]

                if server_type in server_types:
                    server_types[server_type].append(server_name)
                else:
                    server_types[server_type] = [server_name]

                if server_name in ami_types:
                    ami_types[server_name].append(ami_type)
                else:
                    ami_types[server_name] = [ami_type]

    inconsistent_servers = []
    for server_type, server_names in server_types.items():
        for server_name in server_names:
            if not server_name.startswith("web"):
                ami_set = set(ami_types[server_name][0] for server_name in server_names)
                if len(ami_set) > 1:
                    inconsistent_servers.extend([server_name + ' ' + ami_types[server_name][0]])

    for server in inconsistent_servers:
        print(server)

if __name__ == "__main__":
    main()
