#!/usr/bin/env python
# coding: utf-8

import os
import sys
os.path.dirname(sys.executable)

from tkinter import Label
import kivy
from kivy.app import App
from kivymd.app import MDApp
from kivy.uix.widget import Widget
from kivy.vector import Vector
from kivy.clock import Clock
from kivy.uix.screenmanager import ScreenManager, Screen, FadeTransition
from kivy.uix.gridlayout import GridLayout
from kivy.lang import Builder
from kivymd.uix.button import MDRectangleFlatIconButton, MDFillRoundFlatIconButton, MDFillRoundFlatButton
from kivymd.uix.label import MDLabel
from kivymd.uix.screen import MDScreen
from kivymd_extensions.akivymd.uix.progresswidget import AKCircularProgress
from kivymd.uix.behaviors.toggle_behavior import MDToggleButton
from kivy.properties import NumericProperty, ReferenceListProperty, ObjectProperty
# Import game;
from game import *

class MyToggleButton(MDFillRoundFlatIconButton, MDToggleButton):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.background_down = MDApp.get_running_app().theme_cls.primary_dark
        
class ApplicationScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs) 
    pass

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



# class PongPaddle(Widget):
#     score = NumericProperty(0)

#     def bounce_ball(self, ball):
#         if self.collide_widget(ball):
#             vx, vy = ball.velocity
#             offset = (ball.center_y - self.center_y) / (self.height / 2)
#             bounced = Vector(-1 * vx, vy)
#             vel = bounced * 1.1
#             ball.velocity = vel.x, vel.y + offset


# class PongBall(Widget):
#     velocity_x = NumericProperty(0)
#     velocity_y = NumericProperty(0)
#     velocity = ReferenceListProperty(velocity_x, velocity_y)

#     def move(self):
#         self.pos = Vector(*self.velocity) + self.pos


# class PongGame(Widget):
#     ball = ObjectProperty(None)
#     player1 = ObjectProperty(None)
#     player2 = ObjectProperty(None)

#     def __init__(self, *args, **kwargs):
#         super(PongGame, self).__init__(*args, **kwargs)
#         Clock.schedule_interval(self.update, 1.0 / 60.0)

#     def serve_ball(self, vel=(4, 0)):
#         self.ball.center = self.center
#         self.ball.velocity = vel

#     def update(self, dt):
#         self.ball.move()

#         #bounce of paddles
#         self.player1.bounce_ball(self.ball)
#         self.player2.bounce_ball(self.ball)

#     #bounce ball off bottom or top
#         if (self.ball.y < self.y) or (self.ball.top > self.top):
#             self.ball.velocity_y *= -1

#     #went of to a side to score point?
#         if self.ball.x < self.x:
#             self.player2.score += 1
#             self.serve_ball(vel=(4, 0))
#         if self.ball.x > self.width:
#             self.player1.score += 1
#             self.serve_ball(vel=(-4, 0))

#     def on_touch_move(self, touch):
#         if touch.x < self.width / 3:
#             self.player1.center_y = touch.y
#         if touch.x > self.width - self.width / 3:
#             self.player2.center_y = touch.y

class MIMainApp(MDApp):
# we are defining the Base Class of our Kivy App
    def build(self):
        # Create the screen manager
        sm = ScreenManager()
        sm.add_widget(StartScreen(name='menu'))
        sm.add_widget(MainScreen(name='main'))
        sm.add_widget(CoAdaptiveScreen(name='game_screen'))
        sm.add_widget(ProgressWidget(name='progress_widget'))
        sm.add_widget(OfflineTraining(name='offline'))
        sm.add_widget(ApplicationScreen(name='application'))
        return sm
 
if __name__ == '__main__':     
    # Here the class MyApp is initialized
    # and its run() method called.
    sample_app = MIMainApp()
    sample_app.run()






# from kivy.uix.button import Button
# from kivy.uix.widget import Widget
# from kivy.uix.boxlayout import BoxLayout
# from kivy.app import App
# from kivy.graphics import Mesh
# from kivy.uix.tabbedpanel import TabbedPanel
# from kivy.lang import Builder
# from functools import partial
# from math import cos, sin, pi


# class Test(TabbedPanel):
#     pass

# class MainApp(App):
#     def build(self):
#         return Test()

# '''
# TabbedPanel
# ============

# Test of the widget TabbedPanel.
# '''

# Builder.load_string("""

# <Test>:
#     size_hint: .5, .5
#     pos_hint: {'center_x': .5, 'center_y': .5}
#     do_default_tab: False

#     TabbedPanelItem:
#         text: 'first tab'
#         Label:
#             text: 'First tab content area'
    
#     TabbedPanelItem:
#         text: 'tab2'
#         BoxLayout:
#             Label:
#                 text: 'Second tab content area'
#             Button:
#                 text: 'Button that does nothing'
#     TabbedPanelItem:
#         text: 'tab3'
#         RstDocument:
#             text:
#                 '\\n'.join(("Hello world", "-----------",
#                 "You are in the third tab."))

# """)


# class Test(TabbedPanel):
#     pass


# class TabbedPanelApp(App):
#     def build(self):
#         return Test()


# if __name__ == '__main__':
#     TabbedPanelApp().run()



# class MeshTestApp(App):

#     def change_mode(self, mode, *largs):
#         self.mesh.mode = mode

#     def build_mesh(self):
#         """ returns a Mesh of a rough circle. """
#         vertices = []
#         indices = []
#         step = 10
#         istep = (pi * 2) / float(step)
#         for i in range(step):
#             x = 300 + cos(istep * i) * 100
#             y = 300 + sin(istep * i) * 100
#             vertices.extend([x, y, 0, 0])
#             indices.append(i)
#         return Mesh(vertices=vertices, indices=indices)

#     def build(self):
#         wid = Widget()
#         with wid.canvas:
#             self.mesh = self.build_mesh()

#         layout = BoxLayout(size_hint=(1, None), height=50)
#         for mode in ('points', 'line_strip', 'line_loop', 'lines',
#                 'triangle_strip', 'triangle_fan'):
#             button = Button(text=mode)
#             button.bind(on_release=partial(self.change_mode, mode))
#             layout.add_widget(button)

#         root = BoxLayout(orientation='vertical')
#         root.add_widget(wid)
#         root.add_widget(layout)

#         return root



# if __name__ == '__main__':
#     MeshTestApp().run()