#!/usr/bin/env python
# coding: utf-8

import os
import sys
from typing import Dict
os.path.dirname(sys.executable)

# from tkinter import Label
from kivymd.app import MDApp
from kivy.clock import Clock
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.lang import Builder
from kivymd.uix.button import MDFillRoundFlatIconButton
from kivymd.uix.screen import MDScreen
from kivymd_extensions.akivymd.uix.progresswidget import AKCircularProgress
from kivymd.uix.behaviors.toggle_behavior import MDToggleButton
from kivy.properties import NumericProperty, ReferenceListProperty, ObjectProperty
from kivy.uix.image import Image
from kivy.uix.floatlayout import FloatLayout
# Import game;
from game import *

# Client-related imports
from client import Client
import time

class MyToggleButton(MDFillRoundFlatIconButton, MDToggleButton):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.background_down = MDApp.get_running_app().theme_cls.primary_dark
        
class ApplicationScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs) 
    pass



class PredictionScreen(Screen):
    def __init__(self, class_to_results: Dict[int, str], images_base_path: str, **kwargs):
        super(PredictionScreen,self).__init__(**kwargs)

        self.client = Client()
        
        self.images_paths = self._create_images_paths(images_base_path)
        self.ids["prediction_image"].source = self.images_paths["start"]
        
    
    def _create_images_paths(self, images_base_path) -> Dict[str, str]:
        """
        Returns a mapping from the a result name (e.g., "yes") to its respective image path
        """
        # "wait" is currently not used
        results = ["start", "wait", "yes", "no"]

        images_paths = {}
        for res in results:
            images_paths[res] = "{}/{}.jpeg".format(images_base_path, res)

        return images_paths

    def predict(self):
        self.client.connect()
        # TODO: consider adding a "waiting" image while waiting for results.
        # We should probably use a different thread/Future to wait for the prediction result, so the GUI won't be stuck
        
        prediction_raw = self.client.get_prediction_data()
        print("Matalb result: {}".format(prediction_raw))
        result_name = CLASS_TO_RESULT[prediction_raw]
        print("Result name: {}".format(result_name))

        prediction_img_path = self.images_paths[result_name]
        self.ids["prediction_image"].source = prediction_img_path
        time.sleep(1) # Sleep to avoid abrupt connection closing
        self.client.close_connection()

    def reset_screen(self):
        self.client.close_connection()
        self.ids["prediction_image"].source = self.images_paths["start"]
        self.ids["start_stop_button"].text = 'Start'
        


class CoAdaptiveScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs) 
    pass

class StartScreen(Screen):
    def start_mi_game(self):
        run_game()
    pass

class MainScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
    pass    

class ProgressWidget(MDScreen):
    pass

class OfflineTraining(MDScreen):
    pass

class MIMainApp(MDApp):
    def __init__(self, class_to_result, images_base_path, **kwargs):
        super().__init__(**kwargs)
        self.class_to_result = class_to_result
        self.images_base_path = images_base_path

    def build(self):
        # Create the screen manager
        sm = ScreenManager()
        sm.add_widget(StartScreen(name='menu'))
        sm.add_widget(MainScreen(name='main'))
        sm.add_widget(CoAdaptiveScreen(name='game_screen'))
        sm.add_widget(ProgressWidget(name='progress_widget'))
        sm.add_widget(OfflineTraining(name='offline'))
        sm.add_widget(ApplicationScreen(name='application'))
        # TODO: remove PredictionScreen later
        sm.add_widget(PredictionScreen(class_to_results=self.class_to_result, images_base_path=self.images_base_path, name='prediction'))

        self.root_widget = sm

        return sm


# Change according to used classes
CLASS_TO_RESULT = {1: "yes", 2: "no"}
import os.path
current_file_path = os.path.abspath(os.path.dirname(__file__))
IMAGES_BASE_PATH = os.path.join(current_file_path, "images")

if __name__ == '__main__':     
    # Here the class MyApp is initialized
    # and its run() method called.
    app = MIMainApp(CLASS_TO_RESULT, IMAGES_BASE_PATH)
    app.run()


