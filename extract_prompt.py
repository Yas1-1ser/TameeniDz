import json
import sys

with open(r'C:\Users\yasse\.gemini\antigravity-ide\brain\529be18f-be47-4d04-86d3-0901d57257f4\.system_generated\logs\transcript.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        data = json.loads(line)
        if data.get('type') == 'USER_INPUT':
            with open('first_prompt.txt', 'w', encoding='utf-8') as out:
                out.write(data.get('content', ''))
            break
