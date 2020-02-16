# Bulkhead

This project contains a collection of type specific diff scripts. I currently contains two distinct part:

- A bunch of diff scripts
- A Mac app to view the output

## Supported formats

| Description                           | Extension            | Type                                                | Notes                                                      |
| ------------------------------------- | -------------------- | --------------------------------------------------- | ---------------------------------------------------------- |
| Interface Builder Storyboard Document | `storyboard`         | `com.apple.dt.interfacebuilder.document.storyboard` |                                                            |
| JSON Document                         | `json`               | `public.json`                                       |                                                            |
| Office Open XML spreadsheet           | `xlsx`               | `org.openxmlformats.spreadsheetml.sheet`            | Requires [`xlsx2csv`](https://github.com/dilshod/xlsx2csv) |
| Plain Text Document                   | `txt`, …             | `public.plain-text`                                 |                                                            |
| Property List                         | `plist`              | `com.apple.property-list`                           |                                                            |
| Xcode Project Data                    | `pbxproj`, `pbxuser` | `com.apple.xcode.projectdata`                       |                                                            |
| Xcode Scheme                          | `xcscheme`           | `com.apple.dt.document.scheme`                      |                                                            |
| XML Document                          | `xhtml`, `xml`       | `public.xml`                                        |                                                            |

## Diff Scripts

`DiffTools/diff.pl` and `DiffTools/diff-ui.pl` act as entry points to the selection and execution the type specific diff scripts which will compare that given type as they see fit.

`diff.pl` uses `mdls` to give a list of type to try and compare against. It then attempts to find the relevant script to compare the two given files.

For example, comparing an Encel `xls` file will result in the `org.openxmlformats.spreadsheetml.sheet.pl` script being called.

### Git config for UI

```ini
[difftool "Bulkhead"]
  cmd = ???/Bulkhead/DiffTools/diff-ui.sh \"$LOCAL\" \"$REMOTE\"
  path = 
```
