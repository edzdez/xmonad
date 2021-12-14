#!/bin/sh

usbmon() {
	usb1=$(lsblk -la | awk '/sdc1/ { print $1 }')
	usb1mounted=$(lsblk -la | awk '/sdc1/ { print $7 }')

	if [ "$usb1" ]; then
		if [ -z "$usb1mounted" ]; then
			echo " |"
		else
			echo " $usb1 |"
		fi
	fi
}

fsmon() {
	ROOTPART=$(df -h | awk '/\/$/ { print $3}') 
	HOMEPART=$(df -h | awk '/\/home/ { print $3}') 
	SWAPPART=$(cat /proc/swaps | awk '/\// { print $4 }')

	echo "   $ROOTPART    $HOMEPART    $SWAPPART"
}

ram() {
	mem=$(free -h | awk '/Mem:/ { print $3 }' | cut -f1 -d 'i')
	echo   "$mem"
}

cpu() {
	read -r cpu a b c previdle rest < /proc/stat
	prevtotal=$((a+b+c+previdle))
	sleep 0.5
	read -r cpu a b c idle rest < /proc/stat
	total=$((a+b+c+idle))
	cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
	echo  "$cpu"%
}

network() {
	conntype=$(ip route | awk '/default/ { print substr($5,1,1) }')

	if [ -z "$conntype" ]; then
		echo " down"
	elif [ "$conntype" = "e" ]; then
		echo " up"
	elif [ "$conntype" = "w" ]; then
		echo " up"
	fi
}

volume_pa() {
	muted=$(pactl list sinks | awk '/Mute:/ { print $2 }')
	vol=$(pactl list sinks | grep Volume: | awk 'FNR == 1 { print $5 }' | cut -f1 -d '%')

	if [ "$muted" = "yes" ]; then
		echo " muted"
	else
		if [ "$vol" -ge 65 ]; then
			echo " $vol%"
		elif [ "$vol" -ge 40 ]; then
			echo " $vol%"
		elif [ "$vol" -ge 0 ]; then
			echo " $vol%"	
		fi
	fi

}

volume_alsa() {

	mono=$(amixer -M sget Master | grep Mono: | awk '{ print $2 }')

	if [ -z "$mono" ]; then
		muted=$(amixer -M sget Master | awk 'FNR == 6 { print $7 }' | sed 's/[][]//g')
		vol=$(amixer -M sget Master | awk 'FNR == 6 { print $5 }' | sed 's/[][]//g; s/%//g')
	else
		muted=$(amixer -M sget Master | awk 'FNR == 5 { print $6 }' | sed 's/[][]//g')
		vol=$(amixer -M sget Master | awk 'FNR == 5 { print $4 }' | sed 's/[][]//g; s/%//g')
	fi

	if [ "$muted" = "off" ]; then
		echo " muted"
	else
		if [ "$vol" -ge 65 ]; then
			echo " $vol%"
		elif [ "$vol" -ge 40 ]; then
			echo " $vol%"
		elif [ "$vol" -ge 0 ]; then
			echo " $vol%"	
		fi
	fi
}

volume_pulse() {
    SINK=$( pactl list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1 )
    NOW=$( pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,' )
    
	if [ "$NOW" -ge 60 ]; then
	   echo " $NOW%"
	elif [ "$NOW" -ge 40 ]; then
	   echo " $NOW%"
	elif [ "$NOW" -ge 0 ]; then
	   echo " $NOW%"	
	fi
}

battery() {
    cap=$(/bin/cat /sys/class/power_supply/BAT1/capacity)

    if [ "$cap" -ge 90 ]; then
        echo " $cap"
    elif [ "$cap" -ge 75 ]; then
        echo " $cap"
    elif [ "$cap" -ge 50 ]; then
        echo " $cap"
    elif [ "$cap" -ge 25 ]; then
        echo " $cap"
    elif [ "$cap" -ge 0  ]; then
        echo " $cap"
    fi
}

backlight() {
    resdirt=$(brightnessctl | grep % | awk '{print $NF}')
    resnotint=$(echo $resdirt | tr --delete % | tr --delete \( | tr -- delete \))

    echo " $resnotint" | tr --delete \)
}

clock() {
	dte=$(date +"%D")
	time=$(date +"%H:%M")

	echo " $dte  $time"
}

main() {
	while true; do
        xsetroot -name " $(cpu) | $(ram) | $(network) | $(backlight)% | $(battery)% | $(clock)"
		sleep 1s
	done
}

main
