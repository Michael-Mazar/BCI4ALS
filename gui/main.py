#!/usr/bin/env python
# coding: utf-8

import os
import sys
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
# Import game;
from game import *

# Client-related imports
from client import Client
from threading import Thread
import time

class MyToggleButton(MDFillRoundFlatIconButton, MDToggleButton):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.background_down = MDApp.get_running_app().theme_cls.primary_dark
        
class ApplicationScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs) 
    pass


#TODO: remove PredictionScreen later
class PredictionScreen(Screen):
    def __init__(self, **kwargs):
        super(PredictionScreen,self).__init__(**kwargs)

        self.print_thread = None
        self.is_printing = False
        self.client = Client()

    def printer(self):
        while self.is_printing:
            prediction = self.client.get_prediction_data()
            self.ids["debugarea"].text += f'Prediction: {prediction}' + '\n'
            time.sleep(1)

    def do_print(self):
        self.client.connect()

        if not self.is_printing:
            self.is_printing = True
            self.print_thread = Thread(target=self.printer)
            self.print_thread.start()
        else:
            self.is_printing = False
            self.print_thread.join()
            self.print_thread = None
    
    def close_connection(self):
        self.client.close_connection()


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
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

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
        sm.add_widget(PredictionScreen(name='prediction'))

        self.root_widget = sm

        return sm


 
if __name__ == '__main__':     
    # Here the class MyApp is initialized
    # and its run() method called.
    sample_app = MIMainApp()
    sample_app.run()


