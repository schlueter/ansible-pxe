.PHONY: edit

edit:
	find . -type f -not \( -name *.png -o -name *.retry -o -regex .*git.* -o -regex .*\.vagrant.* \) -exec vim {} +
