#!/bin/bash
GODOT="/c/Program Files/Godot/Godot_v4.6.1-stable_win64.exe"
PROJECT_PATH="$(pwd -W)"

PASS=0
FAIL=0

while IFS= read -r -d '' test_file; do
    res_path="res://${test_file#./}"
    echo "Running: $res_path"
    "$GODOT" --headless --path "$PROJECT_PATH" --script "$res_path" 2>&1
    if [ $? -eq 0 ]; then
        ((PASS++))
    else
        ((FAIL++))
    fi
done < <(find . -name "*.test.gd" -not -path "./.godot/*" -print0)

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1