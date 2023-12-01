import os
from mutagen.mp3 import MP3
import random2 as random
from datetime import timedelta
import datetime
import traceback
from PySimpleGUI import PySimpleGUI as sg
import webbrowser
import json

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

class configManager():
    def __init__(self):
        print("Loading config...")
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

class ToolInfo:
    def __init__(self):
        self.__version__ = "0.1.0"
        self.__author__ = "deffcolony"
        self.__contributors__ = ["alexveebee"]

class folderScanner:
    # init : path, scan_subfolders
    def __init__(self, path, scan_subfolders):
        self.path = path
        self.scan_subfolders = scan_subfolders
        # self.scandata = [
        #     {
        #         "path": "",
        #         "files": [
        #             {
        #                 "name": "",
        #                 "duration": 0,
        #             }
        #         ]
        #     }
        # ]

    def get_duration(self, file):
        try:
            audio = MP3(file)
            duration = audio.info.length
            return duration
        except:
            return 0

    def scan(self):
        data = []
        currentdir = self.path
        for root, dirs, files in os.walk(self.path):
            for file in files:
                if file.endswith(".mp3"):
                    file_path = os.path.join(root, file)
                    justpath = os.path.join(root, "")
                    duration = self.get_duration(file_path)
                    data.append({
                        "name": file,
                        "duration": duration,
                        "path": justpath,
                    })
            if not self.scan_subfolders:
                break

        print(f"Scanned {len(data)} files")
        print("#" * 20)

        d = dict()
        d["path"] = currentdir
        d["files"] = data

        return d

class AudioToolbox:
    def __init__(self):
        self.path = ""
        self.file = ""
        self.data = [
            # {
            #     name: "",
            #     duration: 0,
            #     path: "",
            # }
        ]

    def get_file(self):
        self.file = sg.popup_get_file("Select a file to open")
        return self.file

    def get_duration(self, file):
        try:
            audio = MP3(file)
            duration = audio.info.length
            return duration
        except:
            return 0
        
    def get_duration_string(self, file):
        try:
            audio = MP3(file)
            duration = audio.info.length
            return str(timedelta(seconds=duration))
        except:
            return "00:00:00"
        
    def folder_scan(self, path, scan_subfolders):
        self.path = path
        self.data = []
        audoscan = folderScanner(self.path, scan_subfolders)
        self.data = audoscan.scan()
        print("#" * 20 + " SCAN DATA " + "#" * 20)
        print(json.dumps(self.data, indent=4))
        return self.data
        
def sort_scanned_data(data, sorting={
    "sort_by": "name",
    "sort_direction": "asc",
}):
    # if data object is empty
    if len(data) == 0:
        return data
    
def display_data_to_text(data):
    text = ""
    for item in data:
        text += f"{item['name']} - {item['duration']}\n"
    return text

def checkbox_ticked(checkbox):
    if checkbox:
        return True
    else:
        return False

def app():
    print("Starting Audio Toolbox...")
    conf = configManager()
    scandata = []
    scandata_path = []
    total_duration = 0

    sg.theme(conf.get("theme"))

    layout_paths = [[
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

    layout_preview = [
        [
            sg.Button("Randomize order", key="-RANDOMIZE-"),
            sg.Checkbox("Start at 0", key="-START_AT_0-", default=conf.get("start_at_0"), enable_events=True),
        ],
        [
            sg.MLine("", key="-PREVIEW-", expand_x=True, expand_y=True, visible=True, size=(100, 100)),
        ]
    ]

    layout = [
        [
            sg.Column(layout=layout_paths, expand_x=True),
        ],
        [
            sg.Frame(layout=layout_preview, title="Preview", relief=sg.RELIEF_SUNKEN,
                expand_x=True, expand_y=True
            ),
        ]
        # [
        #     sg.Button("Start", key="-START-"),
        #     sg.Button("Cancel", key="-CANCEL-"),
        #     sg.Button("About", key="-ABOUT-"),
        # ]
    ]

    window = sg.Window("Audio Toolbox", layout, size=(1200, 800), finalize=True, resizable=True)

    while True:
        event, values = window.read()
        if event == sg.WIN_CLOSED or event == "-CANCEL-":
            break

        if event == "-INPUT_ADD-":
            conf.set("input_path", values["-FOLDER_PATH-"])
            conf.save_config()

        if event == "-OUTPUT_ADD-":
            conf.set("output_path", values["-OUTPUT_PATH-"])
            conf.save_config()

        if event == "-SCAN_SUBFOLDERS-":
            conf.set("scan_subfolders", values["-SCAN_SUBFOLDERS-"])
            conf.save_config()

        if event == "-SAME_AS_INPUT-":
            conf.set("same_as_input", values["-SAME_AS_INPUT-"])
            conf.save_config()

        if event == "-START_AT_0-":
            conf.set("start_at_0", values["-START_AT_0-"])
            conf.save_config()
            rewrite_preview = []
            start0 = 0
            for item in scandata_path.get("files"):
                itemduration = item["duration"]
                itemduration = int(itemduration)
                if checkbox_ticked(values["-START_AT_0-"]):
                    rewrite_preview.append(f"{format_duration(start0)} - {item['name']}")
                    start0 += itemduration
                else:
                    rewrite_preview.append(f"{format_duration(itemduration)} - {item['name']}")

            rewrite_preview.append(total_duration)
            window["-PREVIEW-"].update("\n".join(rewrite_preview))


        if event == "-SCAN-":
            print("Scanning...")
            preview = []
            
            generatedat = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
            print(f"{cmd_blue}===== SCAN : {generatedat} ====={cmd_reset}")

            if values["-FOLDER_PATH-"] == "":
                sg.popup("Please select a folder to scan")
            else:
                start0 = 0
                total_duration = 0
                audiotoolbox = AudioToolbox()
                scandata = audiotoolbox.folder_scan(values["-FOLDER_PATH-"], values["-SCAN_SUBFOLDERS-"])

                # sort data with path
                scandata_path = scandata.copy()
                scandata_path.get("files").sort(key=lambda x: x["path"])

                for item in scandata.get("files"):
                    itemduration = item["duration"]
                    itemduration = int(itemduration)
                    total_duration += itemduration

                    print(f"{cmd_green}{format_duration(item['duration'])}{cmd_reset} - {item['name']}")
                    print(f"{cmd_yellow}{format_duration(start0)}{cmd_reset} - {item['name']}")
                    if checkbox_ticked(values["-START_AT_0-"]):
                        preview.append(f"{format_duration(start0)} - {item['name']}")
                    else:
                        preview.append(f"{format_duration(itemduration)} - {item['name']}")
                        
                    start0 += itemduration

                total_duration = f"total duration: {format_duration(total_duration)}"
                print(f"{cmd_blue}{total_duration}{cmd_reset}")
                preview.append(total_duration)
                window["-PREVIEW-"].update("\n".join(preview))

        if event == "-RANDOMIZE-":
            print("Randomizing...")
            start0 = 0
            randomizeData = scandata.get("files").copy()
            random.shuffle(randomizeData)
            preview = []

            for item in randomizeData:
                itemduration = item["duration"]
                itemduration = int(itemduration)
                print(f"{cmd_green}{format_duration(item['duration'])}{cmd_reset} - {item['name']}")
                print(f"{cmd_yellow}{format_duration(start0)}{cmd_reset} - {item['name']}")
                if checkbox_ticked(values["-START_AT_0-"]):
                    preview.append(f"{format_duration(start0)} - {item['name']}")
                else:
                    preview.append(f"{format_duration(itemduration)} - {item['name']}")

                start0 += itemduration

                # preview.append(f"{format_duration(item['duration'])} - {item['name']}")
            preview.append(total_duration)
            window["-PREVIEW-"].update("\n".join(preview))

# 


try:
    app()
except Exception as e:
    print("Error: " + str(e))
    print(traceback.format_exc())