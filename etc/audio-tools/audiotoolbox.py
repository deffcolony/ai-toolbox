import os
from mutagen.mp3 import MP3
from datetime import timedelta
import datetime
import traceback
from PySimpleGUI import PySimpleGUI as sg
import webbrowser
import json

class configManager():
    def __init__(self):
        self.config = {
            "theme": "DarkAmber",
            "input_path": "",
            "scan_subfolders": True,
            "output_path": "",
            "same_as_input": False,
            "start_at_0": False,
            "show_square_brackets": True,
        }
        self.load_config()

    def load_config(self):
        # load config
        if os.path.exists("config.json"):
            with open("config.json", "r") as config_file:
                self.config = json.load(config_file)
        else:
            self.save_config()

    def save_config(self):
        # save config
        with open("config.json", "w") as config_file:
            json.dump(self.config, config_file)

    def get(self, key):
        return self.config.get(key, None)

    def set(self, key, value):
        self.config[key] = value

cmd_reset = "\033[0m"
cmd_red = "\033[91m"
cmd_yellow = "\033[93m"
cmd_green = "\033[92m"
cmd_blue = "\033[94m"

cmd_bkg_reset = "\033[49m"
cmd_bkg_red = "\033[101m"
cmd_bkg_yellow = "\033[103m"
cmd_bkg_green = "\033[102m"
cmd_bkg_blue = "\033[104m"

playlist_array = []

def window_preferences(conf):
    settings = {
        "saved": False,
        "reload": False,
        "theme": conf.get("theme"),
    }

    settings["reload"] = False
    settings["saved"] = False
    settings["theme"] = conf.get("theme")

    # general
    page1_layout = [
    ]
    # appearance
    page2_layout = [
        [sg.Text("Theme:"), sg.Combo(sg.theme_list(), default_value=settings["theme"], key="-THEME-", enable_events=True)],
    ]


    layout = [
        [sg.TabGroup([[
            sg.Tab("General", page1_layout), 
            sg.Tab("Appearance", page2_layout)
            ]],
            key="-TABGROUP-",
            expand_x=True,
            expand_y=True,
            )],
        [sg.HSeparator()],
        [sg.Text("About")],
        [sg.Text("Hover over a setting to see a description", key="-DESCRIPTION-")],
        [sg.HSeparator()],
        [sg.Button("Save", key="-SAVE-"), sg.Button("Cancel", key="-CANCEL-")],
    ]

    window = sg.Window("Preferences", layout, modal=True, finalize=True, size=(600, 400), resizable=True)

    while True:
        event, values = window.read()
        if event == sg.WIN_CLOSED:
            break
        if event == "-CLOSE-":
            break

        # settings update
        if event == "-THEME-":
            print(f"Theme: {values['-THEME-']}")
            settings["theme"] = values["-THEME-"]
            settings["reload"] = True

        # buttons
        if event == "-SAVE-":
            settings["saved"] = True
            conf.set("theme", settings["theme"])
            conf.save_config()
            break
        if event == "-CANCEL-":
            conf.load_config()
            settings["theme"] = conf.get("theme")
            settings["reload"] = False
            settings["saved"] = False

            break

    window.close()
    return settings

def window_about():
    layout = [
        [sg.Text("Playlist Generator")],
        [sg.Text("Version 0.1.0")],
        [sg.Text("Original by Deffcolony\nRemastered By AlexVeeBee")],
        # link to github
        [sg.Text("Github: "), sg.Text("deffcolony/ai-toolbox", enable_events=True, key="-GITHUB-", text_color="#8888EE", font=("Helvetica", 10, "underline"))],
        [sg.Button("Close", key="-CLOSE-")],
    ]

    window = sg.Window("About", layout, modal=True, finalize=True, size=(400, 250))

    while True:
        event, values = window.read()
        if event == sg.WIN_CLOSED:
            break
        if event == "-CLOSE-":
            break
        if event == "-GITHUB-":
            webbrowser.open("https://github.com/deffcolony/ai-toolbox/tree/main/etc/audio-tools")
    window.close()

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

# WORK IN PROGRESS
# import win32com.client

# def WIN_fetch_file_metadata(file_path):
#     print(f"Fetching metadata for {file_path}")
#     print(json.dumps({
#         "path": file_path,
#         "name": os.path.basename(file_path),
#         "dir": os.path.dirname(file_path),
#         "ext": os.path.splitext(file_path)[1],
#     }, indent=4))
#     # return a dict with the file metadata
#     # {
#     #   "artist": "Unknown",
#     #   "title": "Unknown",
#     # }
#     metadata = ["Artist", "Title", "Album"]

#     sh=win32com.client.gencache.EnsureDispatch('Shell.Application',0)
#     ns = sh.NameSpace(os.path.dirname(file_path))

#     file_metadata = dict()
#     item = ns.ParseName(str(file_path))
#     for ind, attribute in enumerate(metadata):
#         attr_value = ns.GetDetailsOf(item, ind)
#         if attr_value:
#             file_metadata[attribute] = attr_value

#     print(json.dumps(file_metadata, indent=4))
#     return file_metadata
#     # print(item.ExtendedProperty("Artist"))
#     # print(item.ExtendedProperty("Title"))

#     pass

# object format:
# [
#   {
#      "name": "folder",
#      "duration": 0,
#      "files": [
#           {
#               "name": "file", 
#               "duration": 0
#           }
#       ]
#   },
#   ...
# ]
def scan_folder(folder_path, recursive=False, formating={"start_at_0": False, "square_brackets": True}):
    total_duration = 0
    local_total_duration = 0

    print(f"{cmd_yellow}[Scanning]{cmd_reset} {folder_path}")
    music_files = [file for file in os.listdir(folder_path) if file.endswith(".mp3")]
    preview = []
    data = []
    table_template = {
        "duration": "",
        "path": "",
        "folder": "",
        "items": []
    }
    preview_table = []
    for index, music_file in enumerate(music_files, start=1):
        print(f"{cmd_green}[Found   ]{cmd_reset} {music_file}")
        # WIN_fetch_file_metadata(os.path.join(folder_path, music_file))
        audio = MP3(os.path.join(folder_path, music_file))
        formatted_duration = "[00:00:00]"

        entry = "[] - 00 [Unknown] - [Unknown]\n"
        entry_table = {
            "dur": formatted_duration,
            "index": "",
            "artist": "",
            "name": "",
            "file": ""
        }

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

        entry_table["dur"] = formatted_duration
        entry_table["index"] = index
        entry_table["artist"] = "Unknown"
        entry_table["name"] = os.path.splitext(music_file)[0]
        entry_table["file"] = "Unknown"

        preview.append(entry)
        preview_table.append(entry_table)

    preview.append(f"\nFolder total duration: [{format_duration(local_total_duration)}]\n")

    if not music_files:
        print(f"{cmd_red} No music files found!{cmd_reset}")
        preview.append(f"No files found\n")

    if recursive:
        for folder in os.listdir(folder_path):
            if os.path.isdir(os.path.join(folder_path, folder)):
                wordlength_path = len(folder_path)
                divider = "=" * (wordlength_path + 2)
                
                preview.append(f"\n{divider}\n{folder_path}/{folder}\n{divider}\n")
                # preview_table.append([f"{folder_path}/{folder}", "", "", "", ""])
                # preview_table.append({
                #     "dur": f"{folder_path}/{folder}",
                #     "i": "",
                #     "artist": "",
                #     "name": "",
                #     "file": ""
                # })

                scan = scan_folder(os.path.join(folder_path, folder), recursive, formating)
                final_preview = scan["preview"]

                preview.extend(final_preview)
                data.extend(scan["data"])
                total_duration += scan.get("total_duration", 0)

    table_template["duration"] = format_duration(total_duration)
    table_template["path"] = folder_path
    table_template["folder"] = os.path.basename(folder_path)
    table_template["items"] = preview_table

    data.append(table_template)

    d = dict()
    d["preview"] = preview
    d["preview_table"] = preview_table
    d["total_duration"] = total_duration
    d["data"] = data
    return d


def output_txt(playlist, outfolder):
    if outfolder:
        with open(os.path.join(outfolder, "playlist.txt"), "w") as playlist_file:
            playlist_file.writelines(playlist)
        return "File generated at " + os.path.join(outfolder, "playlist.txt")
    else:
        return "No folder selected!"

def checkbox_ticked(checkbox):
    if checkbox:
        return True
    else:
        return False
    
def main():
    conf = configManager()
    sg.theme(conf.get("theme"))
    playlist_treedata = sg.TreeData()

    layout_preview = [[
        sg.Button("Save Playlist", key="-GENERATE_PLAYLIST-", disabled=True),
        sg.VSeperator(),
        sg.Text("View:"),
        sg.Combo(["Text", "Table"], default_value="Text", key="-VIEW-", enable_events=True),
        sg.VSeperator(),
        sg.Text("Select a folder", key="-STATUS-", size=(40, 1))
    ], [
        sg.Frame(layout=[[
            sg.MLine("", key="-PREVIEW-", expand_x=True, expand_y=True, visible=True, size=(100, 100)),
            # table
            sg.Tree( playlist_treedata,
                     headings=["Duration", "Index", "Artist", "Title", "Filename"],
                     key="-PREVIEW-TABLE-",
                     visible=False,
                     num_rows=10,
                     col_widths=[10, 5, 20, 20, 20],
                     auto_size_columns=False,
                     header_text_color="#FFFFFF",
                     header_background_color="#333333",
                     text_color="#FFFFFF",
                     background_color="#333333",
                     expand_x=True,
                     expand_y=True,
                     enable_events=True,
                     justification="left",
                     select_mode=sg.TABLE_SELECT_MODE_BROWSE,
                     row_height=20,
            ),
        ]], title="Playlist", relief=sg.RELIEF_SUNKEN, expand_x=True, expand_y=True),
    ]]
    
    layout_formating = [[
        # formating
        sg.Frame(layout=[[
            sg.Column(layout=[
                [sg.Text("Ordering:"), sg.Combo(
                    ["Alphabetical", "Chronological", "Artist", "Title", "Size", "lengeth" , "Random"],
                    default_value="Alphabetical", key="-ORDERING-", enable_events=True),
                    sg.Checkbox("Reverse", key="-REVERSE-", default=False, enable_events=True),
                    sg.Button("Sort", key="-SORT-"),
                    ],
                [sg.Checkbox("Start playlist at 00:00", key="-START_AT_0-", default=conf.get("start_at_0"), enable_events=True)],
                [sg.Checkbox("Show square brackets", key="-SHOW_SQUARE_BRACKETS-", default=conf.get("show_square_brackets"), enable_events=True)],
                [sg.Text("Folders/Files excluded from playlist:"), sg.Checkbox("Folder", key="-ENABLE_FOLDER_EXCLUSION-", default=False, enable_events=True), sg.Checkbox("File", key="-ENABLE_FILE_EXCLUSION-", default=False, enable_events=True)],
                [sg.Table(values=[["", "", ""]], headings=["Type","Path", "Name"], key="-EXCLUDED-FOLDERS-", num_rows=10, col_widths=[8, 30, 24], auto_size_columns=False, alternating_row_color="#333333", header_text_color="#FFFFFF", header_background_color="#333333", text_color="#FFFFFF", background_color="#333333",
                        expand_x=True, enable_events=True, justification="left", select_mode=sg.TABLE_SELECT_MODE_BROWSE, row_height=20),
                ],
                [sg.Input(key="-EXCLUDED-FOLDER-"), sg.Button("Add", key="-EXCLUDED-FOLDER-ADD-"), sg.Button("Remove", key="-EXCLUDED-FOLDER-REMOVE-")],
            ], expand_x=True, expand_y=True, scrollable=True, vertical_scroll_only=True),
        ]], title="Formating", relief=sg.RELIEF_SUNKEN, expand_x=True, expand_y=True),
    ]]

    paths_layout = [[
        sg.Frame(layout=[[
            sg.Text("Path:"),
            sg.Input(key="-FOLDER_PATH-", enable_events=True, default_text=conf.get("input_path")),
            sg.FolderBrowse(key="-INPUT_ADD-"),
        ], [
            sg.Button("Scan", key="-SCAN-"),
            sg.Checkbox("Scan subfolders", key="-SCAN_SUBFOLDERS-", default=conf.get("scan_subfolders"), enable_events=True),
        ]], title="Input", relief=sg.RELIEF_SUNKEN,
            expand_x=True, expand_y=True
        ),
        # container
        sg.Frame(layout=[[
            sg.Text("Path:"),
            sg.Input(key="-OUTPUT_PATH-", enable_events=True, default_text=conf.get("output_path")),
            sg.FolderBrowse(key="-OUTPUT_ADD-"),
        ], [
            sg.Checkbox("Output same as input folder", key="-SAME_AS_INPUT-", default=conf.get("same_as_input"), enable_events=True),
        ]], title="Output", relief=sg.RELIEF_SUNKEN,
            expand_x=True, expand_y=True
        )
    ]]

    menu_def = [
        ["&File", ["&Preferences", "&Exit", ], ],
        ["&Help", "&About"], 
        ]

    layout = [
        [sg.Menu(menu_def,
                text_color=sg.COLOR_SYSTEM_DEFAULT,
                background_color=sg.COLOR_SYSTEM_DEFAULT,
                key="-MENU-",
                )],
        [sg.Column(layout=paths_layout, expand_x=True)], 
        [sg.Pane([
            sg.Column(layout_preview, expand_x=True, expand_y=True),
            sg.Column(layout_formating, expand_x=True, expand_y=True),
        ], expand_x=True, expand_y=True, orientation='h', relief=sg.RELIEF_SUNKEN)],
    ]

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


    window = sg.Window("Playlist Generator", layout, size=(1200, 800), finalize=True, resizable=True)


    while True:
        event, values = window.read()
        if event == sg.WIN_CLOSED:
            break

        if event == "About":
            window_about()

        if event == "Preferences":
            update = window_preferences(conf)

            if update["reload"]:
                window.close()
                window = main()
        if event == "Exit":
            break
        elif event == "-VIEW-":
            if values["-VIEW-"] == "Text":
                window["-PREVIEW-"].update(visible=True)
                window["-PREVIEW-TABLE-"].update(visible=False)
            elif values["-VIEW-"] == "Table":
                window["-PREVIEW-"].update(visible=False)
                window["-PREVIEW-TABLE-"].update(visible=True)

        elif event == "-SAME_AS_INPUT-":
            conf.set("same_as_input", values["-SAME_AS_INPUT-"])
            conf.save_config()
            if values["-SAME_AS_INPUT-"]:
                window["-OUTPUT_PATH-"].update(values["-FOLDER_PATH-"])
            else:
                window["-OUTPUT_PATH-"].update("")
                
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

                print(f"{cmd_blue}===== SCAN : {generatedat} ====={cmd_reset}")

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


                # table
                # Empty the table
                # add a row for that spans the entire table
                data = scan.get("data", [])
                playlist_treedata = sg.TreeData()
                for index, item in enumerate(data):
                    playlist_treedata.Insert("", f"folder{index}", item["folder"], values=["", "", "", "", ""])
                    for file in item["items"]:
                        playlist_treedata.Insert(f"folder{index}", f"file{index}", "", values=[
                            file["dur"],
                            file["index"],
                            file["artist"],
                            file["name"],
                            file["file"]
                        ])
                window["-PREVIEW-TABLE-"].update(playlist_treedata)
            except Exception as e:
                print("Error creating preview")
                # go to text view
                window["-VIEW-"].update("Text")
                window["-PREVIEW-"].update(visible=True)
                window["-PREVIEW-TABLE-"].update(visible=False)

                window["-STATUS-"].update("Error creating preview, check console")
                err = [f"Error creating preview: \n{e}\n"]
                window["-PREVIEW-"].update("".join(err))
                window["-GENERATE_PLAYLIST-"].update(disabled=True)
                # log error
                traceback.print_exc()
                window["-PREVIEW-"].print(traceback.format_exc(), end="", background_color="red", text_color="white")

        # path inputs
        elif event == "-FOLDER_PATH-":
            conf.set("input_path", values["-FOLDER_PATH-"])
            conf.save_config()
        elif event == "-OUTPUT_PATH-":
            conf.set("output_path", values["-OUTPUT_PATH-"])
            conf.save_config()

        # checkboxes
        elif event == "-SCAN_SUBFOLDERS-":
            conf.set("scan_subfolders", checkbox_ticked(values["-SCAN_SUBFOLDERS-"]))
            conf.save_config()
        elif event == "-START_AT_0-":
            conf.set("start_at_0", checkbox_ticked(values["-START_AT_0-"]))
            conf.save_config()
        elif event == "-SHOW_SQUARE_BRACKETS-":
            conf.set("show_square_brackets", checkbox_ticked(values["-SHOW_SQUARE_BRACKETS-"]))
            conf.save_config()

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

if __name__ == "__main__":
    main()