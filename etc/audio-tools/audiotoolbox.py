import os
from mutagen.mp3 import MP3
from datetime import timedelta
import datetime
import traceback
from PySimpleGUI import PySimpleGUI as sg

cmd_reset = "\033[0m"
cmd_red = "\033[91m"
cmd_yellow = "\033[93m"
cmd_green = "\033[92m"

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
def days_hours_minutes(td):
    def add0(n):
        if n < 10:
            return f"0{n}"
        else:
            return n
    return f"{add0(td.seconds//3600)}:{add0((td.seconds//60)%60)}:{add0(td.seconds%60)}"

    # return td.days, td.seconds//3600, (td.seconds//60)%60, td.seconds%60
def format_duration(duration):
    return days_hours_minutes(timedelta(seconds=duration))

class folder_scanner:
    # 
    def __init__(self):
        pass
    pass

def scan_folder(folder_path, recursive=False, formating={"start_at_0": False, "square_brackets": True}):
    total_duration = 0
    local_total_duration = 0

    print(f"{cmd_yellow}[Scanning]{cmd_reset} {folder_path}")
    music_files = [file for file in os.listdir(folder_path) if file.endswith(".mp3")]
    preview = []
    for index, music_file in enumerate(music_files, start=1):
        print(f"{cmd_green}[Found   ]{cmd_reset} {music_file}")
        audio = MP3(os.path.join(folder_path, music_file))
        formatted_duration = "[00:00:00]"

        entry = "[] - 00 [Unknown] - [Unknown]\n"

        if not formating["start_at_0"]:
            total_duration += audio.info.length
            local_total_duration += audio.info.length
            duration = format_duration(audio.info.length)
            formatted_duration = f"{formating['square_brackets'] * '['}{duration}{formating['square_brackets'] * ']'}"
            entry = f"{formatted_duration} - {index:02d} {os.path.splitext(music_file)[0]}\n"
        
        if formating["start_at_0"]:
            duration = format_duration(local_total_duration)
            formatted_duration = f"{formating['square_brackets'] * '['}{duration}{formating['square_brackets'] * ']'}"
            total_duration += audio.info.length
            local_total_duration += audio.info.length
            entry = f"{formatted_duration} - {index:02d} {os.path.splitext(music_file)[0]}\n"
        
        preview.append(entry)

    if not music_files:
        print(f"{cmd_red} No music files found!{cmd_reset}")
        preview.append(f"No files found\n")

    if recursive:
        for folder in os.listdir(folder_path):
            if os.path.isdir(os.path.join(folder_path, folder)):
                wordlength_path = len(folder_path)
                wordlength_folder = len(folder)
                divider = "=" * (wordlength_path + 2)
                
                preview.append(f"\n{divider}\n{folder_path}/{folder}\n{divider}\n")
                scan = scan_folder(os.path.join(folder_path, folder), recursive, formating)
                final_preview = scan["preview"]

                preview.extend(final_preview)
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
    sg.Button("Save Playlist", key="-GENERATE_PLAYLIST-", disabled=True),
    sg.VSeperator(),
    sg.Text("Select a folder", key="-STATUS-", size=(40, 1))
],[
    sg.Multiline("", key="-PREVIEW-", expand_x=True, expand_y=True),
    # formating
    sg.Frame(layout=[[
        sg.Column(layout=[
            [sg.Checkbox("Start playlist at 00:00", key="-START_AT_0-")],
            [sg.Checkbox("Show square brackets", key="-SHOW_SQUARE_BRACKETS-", default=True)],
        ], expand_x=True, expand_y=True, scrollable=True, vertical_scroll_only=True),
    ]], title="Formating", relief=sg.RELIEF_SUNKEN, expand_x=True, expand_y=True),
    # sg.Frame(layout=[
    #     [sg.Checkbox("Start playlist at 00:00", key="-START_AT_0-")],
    #     [sg.Checkbox("Show square brackets", key="-SHOW_SQUARE_BRACKETS-")],
    #     [sg.Input(key="-DATE_FORMAT-", size=(10, 1))],
    # ], title="Formating", relief=sg.RELIEF_SUNKEN,
    #     expand_x=True, expand_y=True
    # ),
]]

paths_layout = [[
    sg.Frame(layout=[[
        sg.Text("Path:"),
        sg.Input(key="-FOLDER_PATH-", enable_events=True),
        sg.FolderBrowse(key="-INPUT_ADD-"),
    ], [
        sg.Button("Scan", key="-SCAN-"),
        sg.Checkbox("Scan subfolders", key="-SCAN_SUBFOLDERS-"),
    ]], title="Input", relief=sg.RELIEF_SUNKEN,
        expand_x=True, expand_y=True
    ),
    # container
    sg.Frame(layout=[[
        sg.Text("Path:"),
        sg.Input(key="-OUTPUT_PATH-", enable_events=True),
        sg.FolderBrowse(key="-OUTPUT_ADD-"),
    ], [
        sg.Checkbox("Output same as input folder", key="-SAME_AS_INPUT-"),
    ]], title="Output", relief=sg.RELIEF_SUNKEN,
        expand_x=True, expand_y=True
    )
]]

layout = [[sg.Column(layout=paths_layout, expand_x=True)], [sg.HSeparator() ], [sg.Column(layout=layout_preview, expand_x=True, expand_y=True),]]

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


window = sg.Window("Playlist Generator", layout, size=(1100, 600), finalize=True, resizable=True)


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
        formating = {"start_at_0": values["-START_AT_0-"], "square_brackets": values["-SHOW_SQUARE_BRACKETS-"]}
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

            # show date and time
            generatedat = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")

            print(f"===== SCAN : {generatedat} =====")

            scan = scan_folder(folder_path, recusive, formating)

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
            window["-PREVIEW-"].update("".join(traceback.format_exc()))

    elif event == "-OUTPUT_PATH-":
        window["-STATUS-"].update("Output path selected")

    elif event == "-GENERATE_PLAYLIST-":
        window["-STATUS-"].update("Generating playlist...")
        folder_path = values["-FOLDER_PATH-"]
        outfolder = values["-OUTPUT_PATH-"]

        # is "same as input" checked?
        if outfolder == "":
            outfolder = None

        if values["-SAME_AS_INPUT-"]:
            outfolder = folder_path

        try:
            print(f"Saving playlist to {outfolder}")

            result = output_txt(preview, outfolder)
            window["-STATUS-"].update(result)
        except:
            window["-STATUS-"].update("Error generating playlist")

window.close()