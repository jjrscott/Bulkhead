# Bulkhead

This project contains a collection of type specific diff scripts. I currently contains two distinct part:

- A bunch of diff scripts
- A Mac app to view the output

## Diff Scripts

`DiffTools/diff.pl` and `DiffTools/diff-ui.pl` act as entry points to the selection and execution the type specific diff scripts which will compare that given type as they see fit.

`diff.pl` uses `mdls` to give a list of type to try and compare against. It then attempts to find the relevant script to compare the two given files.

For example, comparing an Encel `xls` file will result in the `org.openxmlformats.spreadsheetml.sheet.pl` script being called.

### Git config for UI

```
[difftool "Bulkhead"]
	cmd = ???/Bulkhead/DiffTools/diff-ui.sh \"$LOCAL\" \"$REMOTE\"
	path = 
```
