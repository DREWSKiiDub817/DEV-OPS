# **Shell Scripts**

* create-and-launch-rocket.sh
* bash create-and-launch-rocket.sh

**Run script as Command**
* create-and-launch-rocket
* export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/michael
* or
* export PATH=$PATH:/home/michael
* run the **which create-and-launch-rocket** to see where the command/script is located
* ls -l /home/michael/create-and-launch-rocket
* chmod +x /home/michael/create-and-launch-rocket
* ls -l /home/michael/create-and-launch-rocket

**BEST Practice**
* Give your script a name that makes sense
* Leave out .sh extension for executables

LAB
* mkdir countries
* cd countries
* mkdir USA India UK
* echo "Washington, D.C" > USA/capital.txt
* echo "London" > UK/capital.txt
* echo "New Delhi" > India/capital.txt
* uptime

**Variables**
* $mission_name
* mission_name = mars-mission
* mission_name = lunar-mission

*create-and-launch-rocket*
* mission_name = mars-mission
* mkdir $mission_name
* rocket-add $mission_name
* rocket-start-power $mission_name
* rocket-internal-power $mission_name
* rocket-crew-ready $mission_name
* rocket-start-sequence $mission_name
* rocket-start-emgine $mission_name
* rocket-lift-off $mission_name
* rocket-status $mission_name
  * or
* rocket_status=$(rocket-status $mission_name)
* echo "Status of launch: $rocket_status"

**Command Line Arguments**
* mission_name = $1
* create-and-launch-rocket jupiter-mission
* create-and-launch-rocket uranus-mission

**Read Inputs**
* read -p "Enter mission name:" mission_name
* 
* create-and-launch-rocket

**Arithmetic Operations**
* expr 6 + 3
* A=6
* B=3
* expr $A + $B
* echo $((A + B))

**Conditional Logic**
```sh
if [ $rocket_status = "failed"]
then
    rocket-debug $mission_name

elif [ $rocket_status = "success"]
then
    echo "This is successful"

else
    echo "The state is not failed or successful"
fi
```
**LOOPS**

*FOR*
```sh
for mission in <list of missions>
do
  bash /home/bob/create-and-launch-rocket $mission
done
```

```sh
for mission in $(cat mission-names.txt)
do
  bash /home/bob/create-and-launch-rocket $mission
done
```

```sh
for mission in {0..100}
do
  create-and-launch-rocket mission-$mission
done
```
```sh
while [ $rocket_status = "launching" ]
do 
  sleep 2
  rocket_status=rocket-status $mission_name
done
if [ $rocket_status = "failed" ]
then
  rocket-debug $mission_name
fi
```

```sh
while true
do
    echo "1. Shutdown"
    echo "2. Restart"
    echo "3. Exit Menu"
    read -p "Enter your choice: " choice

    if [ $choice -eq 1 ]
    then
        shutdown now
    elif [ $choice -eq 2 ]
    then
        shutdown -r now
    then
        break
    else
        continue
    fi

done
```