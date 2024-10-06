<div align="center">

<h1>🎹 Chord to MIDI Converter</h1>

</div>

A user-friendly Python application that converts chord/note progressions into MIDI files. Designed for musicians, hobbyists, and anyone who needs a quick way to generate MIDI files from chord charts without needing to know how to code.

## Features

- **User-Friendly Interface**: Simple and intuitive GUI using `PySimpleGUI`.
- **Chord/Note Progression Input**: Input chord/note progression manually or import from a `.txt` file.
- **MIDI File Export**: Convert chord progressions into a `.mid` file, ready for use in any MIDI-compatible software.
- **Supports**:
  - Chords with octave numbers (e.g., `C4`, `G4/B3`).
  - Major and minor chords (e.g., `A4m` for A minor).
  - Slash chords (e.g., `G4/B3` for G major with B in the bass).
  - Flat and sharp notes (e.g., `Db4`, `F#4`).
- **Error Handling**: Properly handles invalid chord/note formats and provides error messages for corrections.
- **File Import**: Import chord progressions directly from a `.txt` file.

## Getting Started

### Prerequisites

You'll need Python 3 installed on your system.

### Installation

1. Install dependencies from the `requirements.txt` file:

```bash
pip install -r requirements.txt
```

2. Run the application:

```bash
python chord_to_midi.py
```

## How to Use

### Input Chord Progression:

- You can manually input the chord/note progression into the text area in the format `C4 G4/B3 A4m G4 F4 G4 C4` or similar.
- Or, you can click the **Import from File** button to load a progression from a `.txt` file.

### Convert to MIDI:

- After entering or importing the chord progression, click the **Convert to MIDI** button.
- A file explorer will pop up, allowing you to choose the location and name for the saved `.mid` file.

### MIDI File Export:

- The MIDI file will be saved to the selected location, and you can open it with any MIDI-compatible software (e.g., a DAW like FL Studio, Ableton Live, etc.).

### Chord Notation Guide

- Each chord consists of a note letter (A-G), an octave number (e.g., 4 for middle C, 3 for one octave below middle C), and optional chord types or bass notes.

## Examples:

- `C4` – Middle C (C in the 4th octave).
- `G4/B3` – G major with B in the bass.
- `A4m` – A minor chord in the 4th octave.
- `D4/F#4` – D major chord with F# as the bass note.

### Example File Format

The app supports text files like this:

```bash
C4 G4/B3 A4m G4 F4 G4 C4
C4 G4/B3 A4m G4 F4 G4 C4

F4 C4/E4 D4m C4 Bb4 C4 F4
A4 G4 F4 E4 D4 C4 F4
```