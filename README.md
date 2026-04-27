# Rtool-image
# TransPicture Universal Image Format Converter
An **interactive, batch, multi-format** image conversion tool developed using **R + magick**.

Automatic Chinese/English bilingual adaptation | Loop task mode | Multi-select images + batch multi-format export

## 📌 Project Description
`TransPicture()` is a lightweight image processing script designed for research/design/daily office use:
- Written entirely in R, ready to use out of the box
- Fully automatic language switching (automatically adapts to Chinese/English system environments)
- Supports single/batch cross-format image conversion
- Persistent loop mode allows multiple rounds of continuous processing without restarting

## 🚀 Core Features
### Basic Capabilities
- Supported formats: `png / jpg / jpeg / webp / tiff / bmp / gif / svg`
- Automatically detects and installs the `magick` dependency package
- Automatic fallback: if a required directory is missing, **automatically creates an Input folder + a placeholder image** to prevent errors

### Advanced Interaction
1. ✅ **Multi‑select images**: Enter numbers separated by spaces to select multiple images in batch
2. ✅ **Multi‑select export formats**: Export the same source image to multiple formats (e.g., png+jpg+webp) in one go
3. ✅ **Loop task mode**: After one conversion, the tool automatically resets and waits for the next operation
4. ✅ **Custom output directory**: Choose an existing folder or enter `new` to quickly create a new folder
5. ✅ **File conflict protection**: Automatically appends `_1/_2` suffixes to duplicate filenames to prevent overwriting
6. ✅ **Adjustable JPG quality**: Customize compression quality from 1–100
7. ✅ **Global exit mechanism**: Enter `quit` or `q` at any input prompt to safely exit the program

### Safety Mechanisms
- Secondary risk confirmation for system cache/hidden folders
- Full error trapping: a single failure will not interrupt the entire batch task
- Visual operation log: success/failure printed in real time

## 💻 Runtime Environment
- Software: R / RStudio
- Dependency package: `magick` (the script automatically detects and installs it with one click)

## 📥 How to Use
### 1. Prepare the Files
Place the following two files in the **same working directory**:

├─ TransPicture.Rdata   # Function body
└─ README.md            # Project documentation

### 2. Load the Tool
```r
# Load the saved function
load("TransPicture.Rdata")

# Start the interactive converter
TransPicture()
```

## 📖 Standard Workflow
1. The program automatically scans all valid folders in the current directory
2. Select the **input folder** containing the images to convert
3. Enter numbers (space‑separated) to select the images you wish to process
4. Select an output folder (enter `new` to create a new one)
5. Enter numbers (space‑separated) to select the desired export formats
6. Optionally set the JPG compression quality, then press Enter to confirm
7. Automatic batch multi‑format export with duplicate renaming
8. Current round ends → automatically proceeds to the next loop
9. Enter `quit` or `q` at any step to terminate the program

## ⌨️ Shortcut Commands
| Command | Action |
|---------|--------|
| `new`   | Create a new blank output folder |
| `quit` / `q` | Immediately exit the loop program |
| Direct Enter | Keep default parameter (e.g., JPG quality 95) |

## 📂 Directory Rules
- On first run, the program automatically creates `./Input/` as the default input directory
- Includes an `empty.png` placeholder to prevent errors when the directory is empty
- All output files are saved to your selected or newly created output directory

## 🌐 Language Adaptation
- Chinese operating system: full Chinese interactive prompts
- English/overseas system: automatically switches to English interface
- No manual configuration required; the adaptation is completely seamless

## 📊 Output Statistics
At the end of each conversion round, a summary is displayed:
- Number of successfully converted files
- Number of failed files & error reasons
- Total number of files processed in the current round

## 📜 License
This project is an open‑source lightweight tool. Free to modify, customize, and use for personal / non‑commercial purposes.
