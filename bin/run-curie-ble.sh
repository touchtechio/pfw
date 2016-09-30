#DEVICE_ID_0="84:68:3E:00:F3:AC"
#DEVICE_ID_1="84:68:3E:00:F3:BF"
#DEVICE_ID_2="84:68:3E:00:F3:C2"

EXEC="python ble_autostart_collector.py -d"
RECORDED_DATA="python recorded_ble_data.py"
#RECORDED_DATA="echo noop"

while true; do
  echo "Running '$EXEC $DEVICE_ID_0' ..."
  $EXEC $DEVICE_ID_0
  echo "Running '$EXEC $DEVICE_ID_0' ..."
  sleep 1
  $EXEC $DEVICE_ID_0
  echo "Server '$EXEC $DEVICE_ID_0' exited with exit code $?."
    while true; do
      echo "Running '$RECORDED_DATA' once ..."
      $RECORDED_DATA
      echo "Server '$RECORDED_DATA' done with code $?."
      sleep 1
    done
done
