#!/usr/bin/env python
import ast, json, sys; 

def main():
    print(json.dumps(ast.literal_eval(sys.stdin.read()),indent=2))

if __name__ == "__main__":
    main()
