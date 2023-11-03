import os
import tkinter as tk
from tkinter import filedialog
from mutagen.mp3 import MP3
from datetime import timedelta
from datetime import date
import datetime
from tkinter import ttk
from ttkthemes import ThemedTk
import traceback
from PySimpleGUI import PySimpleGUI as sg

# [LENGTH  ] - [INDEX] [ARTIST] - [TITLE                        ]
# [00:00:00] - 01 Purrple Cat   - Traveller
# [00:03:20] - 02 Purrple Cat   - Swimming With Whales
# [00:06:24] - 03 Purrple Cat   - Cold Pizza
# [00:09:20] - 04 Purrple Cat   - Alley Cat
# [00:12:04] - 05 Purrple Cat   - Beyond The Boundary
# [00:15:34] - 06 Purrple Cat   - Moonlit Walk
# [00:18:51] - 07 Purrple Cat   - Out of the Blue
# [00:21:21] - 08 Purrple Cat   - I'll Be There
# [00:23:43] - 09 Purrple Cat   - Wondering
# [00:27:04] - 10 Purrple Cat   - Walking To The Park At 3 A.M

# Function to format the duration as [hh:mm:ss]
def format_duration(duration):
    return str(timedelta(seconds=duration))

# Function to generate the playlist
# def generate_playlist(outfolder = None):
#     # allow all music files
#     folder_path = outfolder
    
#     if folder_path:
#         music_files = [file for file in os.listdir(folder_path) if file.endswith(".mp3")]
#         music_files.sort()

#         playlist = []
#         for index, music_file in enumerate(music_files, start=1):
#             audio = MP3(os.path.join(folder_path, music_file))
#             # format duration as [hh:mm:ss]
#             duration = format_duration(audio.info.length)
#             entry = f"[{duration}] - {index:02d} {os.path.splitext(music_file)[0]}\n"
#             playlist.append(entry)

#         with open("playlist.txt", "w") as playlist_file:
#             playlist_file.writelines(playlist)

#         return "Playlist generated successfully at " + os.path.join(folder_path, "playlist.txt")
#     else:
#         return "No folder selected!"

def c_format_duration(duration):
    return str(timedelta(seconds=duration))

def scan_folder(folder_path, recursive=False):
    print(f"Scanning {folder_path}")
    music_files = [file for file in os.listdir(folder_path) if file.endswith(".mp3")]
    total_duration = 0
    preview = []
    for index, music_file in enumerate(music_files, start=1):
        print(f"Found {music_file}")
        audio = MP3(os.path.join(folder_path, music_file))

        total_duration += audio.info.length
        duration = c_format_duration(audio.info.length)
        formatted_duration = f"[{duration}]"
                        
        entry = f"{formatted_duration} - {index:02d} {os.path.splitext(music_file)[0]}\n"
        
        preview.append(entry)

    if recursive:
        for folder in os.listdir(folder_path):
            if os.path.isdir(os.path.join(folder_path, folder)):
                preview.append(f"\n\n======================\n{folder_path}/{folder}\n======================\n")
                scan = scan_folder(os.path.join(folder_path, folder), recursive)
                preview.extend(scan["preview"])
                total_duration += scan.get("total_duration", 0)

    d = dict()
    d["preview"] = preview
    d["total_duration"] = total_duration
    return d


def output_txt(playlist, outfolder):
    if outfolder:
        with open(os.path.join(outfolder, "playlist.txt"), "w") as playlist_file:
            playlist_file.writelines(playlist)
        return "File generated at " + os.path.join(outfolder, "playlist.txt")
    else:
        return "No folder selected!"

sg.theme("DarkAmber")


layout_preview = [[
    sg.Text("Preview:"),
    sg.VSeperator(),
    sg.Button("Save Playlist", key="-GENERATE_PLAYLIST-"),
    sg.VSeperator(),
    sg.Text("Select a folder", key="-STATUS-", size=(40, 1))
],[
    sg.Multiline("", key="-PREVIEW-", size=(600, 200)),
]]

paths_layout = [[
    sg.Frame(layout=[[
        sg.Text("Input Path:"),
        sg.Input(key="-FOLDER_PATH-", enable_events=True),
        sg.FolderBrowse(key="-INPUT_ADD-"),
    ], [
        sg.Button("Scan", key="-SCAN-"),
        sg.Checkbox("Scan subfolders", key="-SCAN_SUBFOLDERS-"),
    ]], title="Input", relief=sg.RELIEF_SUNKEN, size=(600, 80)),
    # container
    sg.Frame(layout=[[
        sg.Text("Output Path:"),
        sg.Input(key="-OUTPUT_PATH-", enable_events=True),
        sg.FolderBrowse(key="-OUTPUT_ADD-"),
    ], [
        sg.Checkbox("Output same as input folder", key="-SAME_AS_INPUT-"),
    ]], title="Output", relief=sg.RELIEF_SUNKEN, size=(600, 80)),
]]

layout = [[sg.Column(layout=paths_layout)], [sg.HSeparator() ], [sg.Column(layout=layout_preview),]]

# ], [
#     # 

#     sg.Text("Output Path:"),
#     sg.Input(key="-OUTPUT_PATH-"),
#     sg.FolderBrowse(),
# ], [
#     sg.Checkbox("Output same as input folder", key="-SAME_AS_INPUT-"),
# ], [
#     sg.Text("Select a folder", key="-STATUS-", size=(40, 1))
# ]]


window = sg.Window("Playlist Generator", layout, size=(1200, 500), finalize=True, resizable=True)


while True:
    event, values = window.read()
    if event == sg.WIN_CLOSED:
        break
    elif event == "-SAME_AS_INPUT-":
        if values["-SAME_AS_INPUT-"]:
            window["-OUTPUT_PATH-"].update(values["-FOLDER_PATH-"])
        else:
            window["-OUTPUT_PATH-"].update("")
    # FolderBrowse 
    elif event == "-INPUT_ADD-":
        window["-STATUS-"].update("Adding input path...")
    elif event == "-OUTPUT_ADD-":
        window["-STATUS-"].update("Adding output path...")
    # inputs
    elif event == "-SCAN-":
        # scan the folder
        window["-STATUS-"].update("Creating preview...")
        folder_path = values["-FOLDER_PATH-"]
        window["-PREVIEW-"].update("")
        recusive = values["-SCAN_SUBFOLDERS-"]
        total_duration = 0
        preview = []
        try:
            music_files = [file for file in os.listdir(folder_path) if file.endswith(".mp3")]
            music_files.sort()

            generatedat = date.today().strftime("%d/%m/%Y")

            scan = scan_folder(folder_path, recusive)

            total_duration = scan.get("total_duration", 0)

            # preview.append(f"\nTotal duration: {format_duration(total_duration)}")
            # append at top
            preview.extend(f"Generated at {generatedat}\nTotal duration: [{format_duration(total_duration)}]\n===================================\n\n")
            preview.extend(f"Folder: {folder_path}\n===================================\n\n")
            preview.extend(scan.get("preview", []))
            window["-PREVIEW-"].update("".join(preview))
            window["-STATUS-"].update("Preview created")
            window["-GENERATE_PLAYLIST-"].update(disabled=False)
        except Exception as e:
            window["-STATUS-"].update("Error creating preview, check console")
            err = [f"Error creating preview: \n{e}\n"]
            window["-PREVIEW-"].update("".join(err))
            window["-GENERATE_PLAYLIST-"].update(disabled=True)
            # log error
            print("Error creating preview")
            traceback.print_exc()

    elif event == "-OUTPUT_PATH-":
        window["-STATUS-"].update("Output path selected")

    elif event == "-GENERATE_PLAYLIST-":
        window["-STATUS-"].update("Generating playlist...")
        folder_path = values["-FOLDER_PATH-"]
        outfolder = values["-OUTPUT_PATH-"]
        if outfolder == "":
            outfolder = None
        try:
            result = output_txt(preview, outfolder)
            window["-STATUS-"].update(result)
        except:
            window["-STATUS-"].update("Error generating playlist")

window.close()



# # Create the main application window with the "plastik" theme
# root = ThemedTk(theme="plastik")
# root.title("Playlist Generator")

# # Set the initial window size
# root.geometry("600x400")  # Adjust the size as needed

# # Create and configure the label
# label = ttk.Label(root, text="Select a folder to generate a playlist")
# label.pack(pady=10)

# # Create and configure the Generate Playlist button
# generate_button = ttk.Button(root, text="Generate Playlist", command=generate_playlist)
# generate_button.pack()

# # Create and configure the status label
# status_label = ttk.Label(root, text="")
# status_label.pack(pady=10)

# root.mainloop()
