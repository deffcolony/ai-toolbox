import FreeSimpleGUI as sg
import pretty_midi
import re

# Function to convert chord progression to MIDI
def chords_to_midi(chord_progression, filename):
    # Define basic mapping for notes with octaves (C4 is middle C, G4 is G above middle C, etc.)
    notes = {
        'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4, 'F': 5, 'F#': 6, 'Gb': 6,
        'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11
    }
    
    # Create a PrettyMIDI object
    midi = pretty_midi.PrettyMIDI()
    
    # Add an instrument (Acoustic Grand Piano)
    piano_program = pretty_midi.instrument_name_to_program('Acoustic Grand Piano')
    piano = pretty_midi.Instrument(program=piano_program)
    
    # Split the progression into individual chords/notes
    lines = chord_progression.splitlines()  # Split by lines
    time = 0.0  # Initialize time for note start
    
    # Function to calculate MIDI note number
    def get_midi_note(note, octave):
        return 12 * (int(octave) + 1) + notes[note]
    
    for line in lines:
        # Ignore empty lines
        if not line.strip():
            continue

        # Split the line into chords/notes
        chords = line.split()
        for chord in chords:
            # Regular expression to match the chord/notes with octave (e.g., C4, G4/B3)
            match = re.match(r"([A-G][#b]?)(\d)(m?)(?:/([A-G][#b]?)(\d))?", chord)
            if match:
                root_note = match.group(1)  # Root note (e.g., C, G#)
                root_octave = match.group(2)  # Root note's octave (e.g., 4)
                is_minor = match.group(3)  # Check for minor chord (optional)
                bass_note = match.group(4)  # Bass note for slash chord (optional)
                bass_octave = match.group(5)  # Bass note's octave (optional)
                
                # Create a MIDI note for the root
                root_midi_note = get_midi_note(root_note, root_octave)
                root_velocity = 100 if not is_minor else 80  # Lower velocity for minor chords
                root = pretty_midi.Note(velocity=root_velocity, pitch=root_midi_note, start=time, end=time + 1.0)
                piano.notes.append(root)

                # If there's a bass note (slash chord), add it
                if bass_note and bass_octave:
                    bass_midi_note = get_midi_note(bass_note, bass_octave)
                    bass = pretty_midi.Note(velocity=100, pitch=bass_midi_note, start=time, end=time + 1.0)
                    piano.notes.append(bass)
                
                time += 1.0
            else:
                raise ValueError(f"Invalid chord format: {chord}")

    # Add the piano instrument to the PrettyMIDI object
    midi.instruments.append(piano)
    
    # Write out the MIDI file
    midi.write(filename)

# Function to read chord progression from file
def read_chord_file(filepath):
    try:
        with open(filepath, 'r') as file:
            return file.read()
    except Exception as e:
        sg.popup_error(f"Error reading file: {e}")
        return None

# Layout for the GUI
layout = [
    [sg.Text("Enter Chord/Note Progression or Import a File:")],
    [sg.Multiline(size=(50, 10), key='-CHORDS-', tooltip="Enter chords (e.g. C4 G4/B3 A4m)")],
    [sg.Button('Import from File', key='-IMPORT-')],
    [sg.Button('Convert to MIDI'), sg.Button('Exit')]
]

# Create the window
window = sg.Window("Chord to MIDI Converter", layout)

while True:
    event, values = window.read()

    if event == sg.WINDOW_CLOSED or event == 'Exit':
        break
    
    # Handle file import
    if event == '-IMPORT-':
        file_path = sg.popup_get_file("Select a .txt file", file_types=(("Text Files", "*.txt"),))
        if file_path:
            chords = read_chord_file(file_path)
            if chords:
                window['-CHORDS-'].update(chords)
    
    # Handle MIDI conversion
    if event == 'Convert to MIDI':
        chord_progression = values['-CHORDS-']
        if chord_progression.strip() == "":
            sg.popup_error("Please enter or import a chord progression.")
        else:
            # Prompt user to choose save location
            save_path = sg.popup_get_file("Save MIDI File", save_as=True, default_extension=".mid", file_types=(("MIDI Files", "*.mid"),))
            if save_path:
                try:
                    chords_to_midi(chord_progression, save_path)
                    sg.popup("MIDI file saved successfully!")
                except Exception as e:
                    sg.popup_error(f"Error: {e}")

# Close the window
window.close()
