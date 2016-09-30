#DEVICE_ID_0="84:68:3E:00:F3:AC"
#DEVICE_ID_1="84:68:3E:00:F3:BF"
#DEVICE_ID_2="84:68:3E:00:F3:C2"

EXEC="python ble_autostart_collector.py -d"
#RECORDED_DATA="python recorded_ble_data.py"
RECORDED_DATA="echo noop"

while true; do
    echo "Running '$EXEC $DEVICE_ID_0' ..."
    $EXEC $DEVICE_ID_0
    echo "Server '$EXEC $DEVICE_ID_0' exited with exit code $?."
    echo "Running '$EXEC $DEVICE_ID_1' ..."
    $EXEC $DEVICE_ID_1
    echo "Server '$EXEC $DEVICE_ID_1' exited with exit code $?."
    echo "Running '$EXEC $DEVICE_ID_2' ..."
    $EXEC $DEVICE_ID_2
    echo "Server '$EXEC $DEVICE_ID_2' exited with exit code $?."
    echo "Running '$RECORDED_DATA' once ..."
    $RECORDED_DATA
    echo "Server '$RECORDED_DATA' done with code $?."
    echo "Running '$RECORDED_DATA' twice ..."
    $RECORDED_DATA
    echo "Server '$RECORDED_DATA' done with code $?."
    echo "Running '$RECORDED_DATA' thrice ..."
    $RECORDED_DATA
    echo "Server '$RECORDED_DATA' done with code $?."
    sleep 1
done
