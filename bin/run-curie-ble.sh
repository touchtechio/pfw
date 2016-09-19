DEVICE_ID_0="84:68:3E:00:F3:C2"
DEVICE_ID_1="84:68:3E:00:F3:C2"
DEVICE_ID_2="84:68:3E:00:F3:C2"

EXEC="python curie_ble.py -d"
while true; do
    $EXEC $DEVICE_ID_0
    echo "Server '$EXEC $DEVICE_ID_0' crashed with exit code $?.  Respawning.." >&2
    sleep 1
    $EXEC $DEVICE_ID_1
    echo "Server '$EXEC $DEVICE_ID_1' crashed with exit code $?.  Respawning.." >&2
    sleep 1
    $EXEC $DEVICE_ID_2
    echo "Server '$EXEC $DEVICE_ID_2' crashed with exit code $?.  Respawning.." >&2
    sleep 1
done
