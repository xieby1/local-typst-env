TEST_NIXs = $(shell find . -name test.nix)
test: $(addsuffix .run, ${TEST_NIXs})
%test.nix.run: %test.nix
	nix eval -f $< | tee /dev/tty | grep -q '\[ \]'
