arch=$(uname  -m)
if [ "$arch" = "aarch64" ]; then
	echo "it's aarch64"
	qemu-system-aarch64 -M virt,gic-version=2 -cpu cortex-a72 -m 1G -kernel armos -nographic -serial mon:stdio
else
	qemu-system-aarch64 -M virt -cpu cortex-a57 -m 2G -kernel armos -nographic -serial mon:stdio 
fi
	
