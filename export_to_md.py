import os
import fnmatch

def export_project_to_md(root_dir, output_file, exclude_dirs=None, exclude_exts=None):
    if exclude_dirs is None:
        exclude_dirs = ['.git', 'node_modules', 'vendor', 'build', '.dart_tool', 'linux', 'macos', 'windows', 'web', 'ios', 'android', 'storage', 'bootstrap/cache', '.idea', '.vscode']
    if exclude_exts is None:
        exclude_exts = ['.png', '.jpg', '.jpeg', '.gif', '.ico', '.svg', '.lock', '.exe', '.dll', '.so', '.dylib', '.zip', '.tar', '.gz', '.db', '.sqlite', '.sqlite3', '.apk', '.aab', '.ttf', '.woff', '.woff2']

    with open(output_file, 'w', encoding='utf-8') as outfile:
        outfile.write(f"# Project Export: {os.path.basename(root_dir)}\n\n")
        
        for dirpath, dirnames, filenames in os.walk(root_dir):
            # Modifying dirnames in place to skip excluded directories
            dirnames[:] = [d for d in dirnames if d not in exclude_dirs]
            
            for filename in filenames:
                # Check for excluded extensions
                if any(filename.lower().endswith(ext) for ext in exclude_exts):
                    continue
                
                filepath = os.path.join(dirpath, filename)
                rel_path = os.path.relpath(filepath, root_dir)
                
                # Determine language for markdown code block
                ext = os.path.splitext(filename)[1].lower()
                lang = ext[1:] if ext else 'text'
                if lang == 'dart': lang = 'dart'
                elif lang == 'php': lang = 'php'
                elif lang == 'js': lang = 'javascript'
                elif lang == 'py': lang = 'python'
                elif lang == 'html': lang = 'html'
                elif lang == 'css': lang = 'css'
                
                try:
                    with open(filepath, 'r', encoding='utf-8') as infile:
                        content = infile.read()
                        outfile.write(f"## File: `{rel_path}`\n\n")
                        outfile.write(f"```{lang}\n")
                        outfile.write(content)
                        if not content.endswith('\n'):
                            outfile.write('\n')
                        outfile.write("```\n\n")
                except Exception as e:
                    outfile.write(f"## File: `{rel_path}`\n\n")
                    outfile.write(f"> Could not read file: {e}\n\n")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python export_to_md.py <project_directory> [output_file]")
        sys.exit(1)
        
    project_dir = sys.argv[1]
    output = sys.argv[2] if len(sys.argv) > 2 else 'project_export.md'
    
    print(f"Exporting {project_dir} to {output}...")
    export_project_to_md(project_dir, output)
    print("Done!")
