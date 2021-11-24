#Real stuff
git_fetch () {
	pageant "${ssh_key}"
	git fetch &
	wait $!

	if [ $? -ne 0 ]
	then
		echo "Git Fetch failed."
		exit $fetch_outcome
	fi
}

git_reset () {
	git reset --hard $git_branch &
	wait $!

	if [ $? -ne 0 ]
	then
		echo "Git Reset failed."
		exit $?
	fi
}

dotnet_build () {
	dotnet build --nologo --configuration $dotnet_config &
	wait $!

	if [ $? -ne 0 ]
	then
		echo "Dotnet Build failed."
		exit $?
	fi
}

dotnet_test () {
	dotnet test --configuration $dotnet_config --no-build --nologo -l "console;verbosity=detailed" &
	wait $!

	if [ $? -ne 0 ]
	then
		echo "Dotnet Test failed."
		exit $?
	fi
}

publish() {
	barrier &
	wait $!

	appcmd stop site $iis_site
	net stop W3SVC

	mv "C:/inetpub/wwwroot/${iis_site}/appsettings.json" "./appsettings.json.${iis_site}.bak"
	rm -Rf "C:/inetpub/wwwroot/${iis_site}/*"

	dotnet publish --configuration $dotnet_config --no-build --nologo -o "C:/inetpub/wwwroot/${iis_site}/"

	mv "./appsettings.json.${iis_site}.bak" "C:/inetpub/wwwroot/${iis_site}/appsettings.json"
	
	net start W3SVC
	appcmd start site $iis_site
}

yes_or_no() {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

barrier() {
	lock_path='C:/Temp/deploy_lock'
	trap "rm ${lock_path}" EXIT

	LOCK=$(cat $lock_path)

	while [ ! -z $LOCK ]
	do
	        ALIVE=$(ls /proc | grep $LOCK | wc -l)

	        if [ $ALIVE -gt 0 ]
	        then
	            echo "Another concurrent is running"
	            sleep 10
	        else
	        	echo $$ > $lock_path
	        	break
	        fi
    done

    echo $$ > $lock_path
}
