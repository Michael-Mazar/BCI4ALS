from kivy.app import App
from kivy.core.image import Image
from kivy.uix.widget import Widget
from kivy.properties import ObjectProperty, NumericProperty
from kivy.clock import Clock
from kivy.core.window import Window
from kivy.uix.screenmanager import ScreenManager, Screen, FadeTransition
from kivy.uix.relativelayout import RelativeLayout
from kivy.uix.label import CoreLabel
from kivy.graphics import Rectangle


from kivy.lang import Builder
# from numpy import source

class BaseWidget(Widget):
    '''
    An intermediate Widget subclass serving as a base class for our custom widgets
    '''
    def load_tileable(self, name):
        '''
         Example: a call to load_tileable('grass') will load the file called grass.png 
         and store the resulting texture in a self.tx_grass attribute
        '''
        t = Image('{}.png'.format(name)).texture
        # t = Image(source='floor.png').texture
        t.wrap = 'repeat'
        # t.uvsize = (Window.width / t.width, -1)
        setattr(self, 'tx_%s' % name, t)
        # Set attribute for xlass to be used with kv file
        
class MainScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.game = Background()
        self.add_widget(self.game)
    pass

class Background(Widget):
    tx_floor = ObjectProperty(None)
    tx_grass = ObjectProperty(None)
    tx_cloud = ObjectProperty(None)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Create textures
        self.cloud_texture = Image("clouds.png").texture
        self.cloud_texture.wrap = 'repeat'
        self.cloud_texture.uvsize = (Window.width / self.cloud_texture.width + 5, -1)

        self.floor_texture = Image("complete_bg.png").texture
        self.floor_texture.wrap = 'repeat'
        self.floor_texture.uvsize = (Window.width / self.floor_texture.width, -1)

        # Set the empty key sets
        self.keysPressed = set()
        self._entities = set()
   
    def update(self):
        self.image.x -= 2
        self.image_dupe.x -= 2
        if self.image.right <= 0:
            self.image.x = 0
            self.image_dupe.x = self.width

class GameWidget(Widget):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._keyboard = Window.request_keyboard(
            self._on_keyboard_closed, self)
        self._keyboard.bind(on_key_down=self._on_key_down)
        self._keyboard.bind(on_key_up=self._on_key_up)

        self.register_event_type("on_frame")
        # with self.canvas:
        #     Rectangle(source="assets/background.png", pos=(0, 0),
        #               size=(Window.width, Window.height))
        #     self._score_instruction = Rectangle(texture=self._score_label.texture, pos=(
        #         0, Window.height - 50), size=self._score_label.texture.size)

        self.keysPressed = set()
        self._entities = set()

        Clock.schedule_interval(self._on_frame, 0)
    def _on_frame(self, dt):
        self.dispatch("on_frame", dt)

    def on_frame(self, dt):
        pass
    @property
    def score(self):
        return self._score

    @score.setter
    def score(self, value):
        self._score = value
        self._score_label.text = "Score: " + str(value)
        self._score_label.refresh()
        self._score_instruction.texture = self._score_label.texture
        self._score_instruction.size = self._score_label.texture.size

    def add_entity(self, entity):
        self._entities.add(entity)
        self.canvas.add(entity._instruction)

    def remove_entity(self, entity):
        if entity in self._entities:
            self._entities.remove(entity)
            self.canvas.remove(entity._instruction)

    def collides(self, e1, e2):
        r1x = e1.pos[0]
        r1y = e1.pos[1]
        r2x = e2.pos[0]
        r2y = e2.pos[1]
        r1w = e1.size[0]
        r1h = e1.size[1]
        r2w = e2.size[0]
        r2h = e2.size[1]

        if (r1x < r2x + r2w and r1x + r1w > r2x and r1y < r2y + r2h and r1y + r1h > r2y):
            return True
        else:
            return False

    def colliding_entities(self, entity):
        result = set()
        for e in self._entities:
            if self.collides(e, entity) and e != entity:
                result.add(e)
        return result

    def _on_keyboard_closed(self):
        self._keyboard.unbind(on_key_down=self._on_key_down)
        self._keyboard.unbind(on_key_up=self._on_key_up)
        self._keyboard = None

    def _on_key_down(self, keyboard, keycode, text, modifiers):
        self.keysPressed.add(keycode[1])

    def _on_key_up(self, keyboard, keycode):
        text = keycode[1]
        if text in self.keysPressed:
            self.keysPressed.remove(text)

class Entity(object):
    def __init__(self):
        self._pos = (0, 0)
        self._size = (50, 50)
        self._source = "bullshit.png"
        self._instruction = Rectangle(
            pos=self._pos, size=self._size, source=self._source)
    @property
    def pos(self):
        return self._pos

    @pos.setter
    def pos(self, value):
        self._pos = value
        self._instruction.pos = self._pos

    @property
    def size(self):
        return self._size

    @size.setter
    def size(self, value):
        self._size = value
        self._instruction.size = self._size

    @property
    def source(self):
        return self._source

    @source.setter
    def source(self, value):
        self._source = value
        self._instruction.source = self._source

class Player(Entity):
    def __init__(self):
        super().__init__()
        self.source = "tennisball.png"
        game.bind(on_frame=self.move_step)
        self._shoot_event = Clock.schedule_interval(self.shoot_step, 0.5)
        self.pos = (400, 0)

    def stop_callbacks(self):
        game.unbind(on_frame=self.move_step)
        self._shoot_event.cancel()

    def shoot_step(self, dt):
        # shoot
        if "spacebar" in game.keysPressed:
            x = self.pos[0]
            y = self.pos[1] + 50
            game.add_entity(Bullet((x, y)))

    def move_step(self, sender, dt):
        # move
        step_size = 200 * dt
        newx = self.pos[0]
        newy = self.pos[1]
        if "a" in game.keysPressed:
            newx -= step_size
        if "d" in game.keysPressed:
            newx += step_size
        self.pos = (newx, newy)



class KivyBallApp(App):
    """
    Kivy looks for a Kv file with the same name as your App class in lowercase, minus “App”
    """
    def build(self):
        sm = ScreenManager()
        sm.add_widget(MainScreen(name='main'))
        # game = Background()
        # return game
        return sm
    # def on_start(self):
    #     self.background = self.root.ids.background
    #     Clock.schedule_interval(self.update, 0.016)

if __name__ == "__main__":
    game = GameWidget()
    game.player = Player()
    game.player.pos = (Window.width - Window.width/3, 0)
    game.add_entity(game.player)
    KivyBallApp().run()