arch=$(uname  -m)
if [ "$arch" = "aarch64" ]; then
	qemu-system-aarch64 -M virt -cpu host --enable-kvm -m 1024 -kernel armos -nographic -serial mon:stdio 
else
	qemu-system-aarch64 -M virt -cpu cortex-a57 -m 1024 -kernel armos -nographic -serial mon:stdio 
fi
	
