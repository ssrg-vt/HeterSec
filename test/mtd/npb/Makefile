X86_IP = 10.4.4.100
ARM_IP = 10.4.4.101

all:
	for W in bt cg dc ep ft is lu mg sp ua; do \
		make -C $$W; \
	done

.PHONY: clean
clean:
	for W in bt cg dc ep ft is lu mg sp ua; do \
		make -C $$W clean; \
		rm -f $$W/npbparams.h; \
	done

.PHONY: S A B
S: clean
	./setclass.sh S
A: clean
	./setclass.sh A
B: clean
	./setclass.sh B

install: all
	for W in bt cg dc ep ft is lu mg sp ua; do \
		scp $$W/$${W}_aarch64 $$W/$${W}_x86-64 popcorn@${X86_IP}:; \
		scp $$W/$${W}_aarch64 $$W/$${W}_x86-64 popcorn@${ARM_IP}:; \
		ssh popcorn@${X86_IP} cp $${W}_x86-64 $$W; \
		ssh popcorn@${ARM_IP} cp $${W}_aarch64 $$W; \
	done

.PHONY: help
help:
	@echo "make {all | S | A | B | clean | install}"
