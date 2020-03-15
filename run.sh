arch=$(uname  -m)
if [ "$arch" = "aarch64" ]; then
#	/root/qemu/aarch64-softmmu/qemu-system-aarch64 -M virt -cpu host --enable-kvm -m 1024 -kernel armos -nographic -serial mon:stdio -s -S
	echo "it's aarch64"
	qemu-system-aarch64 -M virt -cpu host --enable-kvm -m 1024 -kernel armos -nographic -serial mon:stdio  -s -S
else
	qemu-system-aarch64 -M virt -cpu cortex-a57 -m 1024 -kernel armos -nographic -serial mon:stdio 
fi
	
