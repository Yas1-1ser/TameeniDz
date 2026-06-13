import os
import re

def parse_errors():
    error_pattern = re.compile(r'\s*(error|warning)\s+-\s+(.*?)\s+-\s+(.*?):(\d+):(\d+)\s+-\s+(.*)')
    errors_by_file = {}
    with open(r'scratch\analyze_output_2.txt', 'r', encoding='utf-16') as f:
        for line in f:
            match = error_pattern.match(line)
            if match:
                severity = match.group(1)
                message = match.group(2)
                file_path = match.group(3)
                line_no = int(match.group(4))
                col_no = int(match.group(5))
                error_id = match.group(6)
                
                if severity == 'error':
                    file_path = file_path.replace('\\', '/')
                    if file_path not in errors_by_file:
                        errors_by_file[file_path] = []
                    errors_by_file[file_path].append({
                        'message': message,
                        'line': line_no,
                        'col': col_no,
                        'id': error_id
                    })
    return errors_by_file

if __name__ == '__main__':
    errors = parse_errors()
    print(f"Total files with errors: {len(errors)}")
    for file, errs in errors.items():
        print(f"\n{file} ({len(errs)} errors):")
        for e in errs:
            print(f"  Line {e['line']}: {e['id']} - {e['message']}")
