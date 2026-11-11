#!/usr/bin/env bash
# Poll the OrangeFox cupid CI run until it finishes.
export GH_TOKEN=$(printf 'protocol=https\nhost=github.com\n\n' | git credential fill | sed -n 's/^password=//p')
RUN=42913623047
REPO=hrihq/Orangefox-A17-Cupid
for i in $(seq 1 100); do
  S=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
      "https://api.github.com/repos/$REPO/actions/runs/$RUN" \
      | python -c "import sys,json;d=json.load(sys.stdin);print(d['status'],d.get('conclusion'))" 2>/dev/null)
  echo "[$(date -u +%H:%M:%S)] poll $i: $S"
  case "$S" in
    "completed "*) echo "RUN FINISHED: $S"; break;;
  esac
  sleep 60
done
echo "=== final jobs ==="
curl -s -H "Authorization: Bearer $GH_TOKEN" \
  "https://api.github.com/repos/$REPO/actions/runs/$RUN/jobs" \
  | python -c "
import sys,json
d=json.load(sys.stdin)
for j in d.get('jobs',[]):
    print('JOB',j['name'],j['conclusion'])
    for s in j['steps']:
        print('  ',s['number'],s['name'],s['conclusion'])
"
