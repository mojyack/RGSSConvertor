#==============================================================================
# ■ Scene_File
#------------------------------------------------------------------------------
# 　セーブ画面とロード画面の共通処理を行うクラスです。
#==============================================================================

class Scene_File < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_savefile_viewport
    create_savefile_windows
    init_selection
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    @savefile_viewport.dispose
    @savefile_windows.each {|window| window.dispose }
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @savefile_windows.each {|window| window.update }
    update_savefile_selection
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.set_text(help_window_text)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウのテキストを取得
  #--------------------------------------------------------------------------
  def help_window_text
    return ""
  end
  #--------------------------------------------------------------------------
  # ● セーブファイルビューポートの作成
  #--------------------------------------------------------------------------
  def create_savefile_viewport
    @savefile_viewport = Viewport.new
    @savefile_viewport.rect.y = @help_window.height
    @savefile_viewport.rect.height -= @help_window.height
  end
  #--------------------------------------------------------------------------
  # ● セーブファイルウィンドウの作成
  #--------------------------------------------------------------------------
  def create_savefile_windows
    @savefile_windows = Array.new(item_max) do |i|
      Window_SaveFile.new(savefile_height, i)
    end
    @savefile_windows.each {|window| window.viewport = @savefile_viewport }
  end
  #--------------------------------------------------------------------------
  # ● 選択状態の初期化
  #--------------------------------------------------------------------------
  def init_selection
    @index = first_savefile_index
    @savefile_windows[@index].selected = true
    self.top_index = @index - visible_max / 2
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    DataManager.savefile_max
  end
  #--------------------------------------------------------------------------
  # ● 画面内に表示するセーブファイル数を取得
  #--------------------------------------------------------------------------
  def visible_max
    return 4
  end
  #--------------------------------------------------------------------------
  # ● セーブファイルウィンドウの高さを取得
  #--------------------------------------------------------------------------
  def savefile_height
    @savefile_viewport.rect.height / visible_max
  end
  #--------------------------------------------------------------------------
  # ● 最初に選択状態にするファイルインデックスを取得
  #--------------------------------------------------------------------------
  def first_savefile_index
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 現在のインデックスの取得
  #--------------------------------------------------------------------------
  def index
    @index
  end
  #--------------------------------------------------------------------------
  # ● 先頭のインデックスの取得
  #--------------------------------------------------------------------------
  def top_index
    @savefile_viewport.oy / savefile_height
  end
  #--------------------------------------------------------------------------
  # ● 先頭のインデックスの設定
  #--------------------------------------------------------------------------
  def top_index=(index)
    index = 0 if index < 0
    index = item_max - visible_max if index > item_max - visible_max
    @savefile_viewport.oy = index * savefile_height
  end
  #--------------------------------------------------------------------------
  # ● 末尾のインデックスの取得
  #--------------------------------------------------------------------------
  def bottom_index
    top_index + visible_max - 1
  end
  #--------------------------------------------------------------------------
  # ● 末尾のインデックスの設定
  #--------------------------------------------------------------------------
  def bottom_index=(index)
    self.top_index = index - (visible_max - 1)
  end
  #--------------------------------------------------------------------------
  # ● セーブファイル選択の更新
  #--------------------------------------------------------------------------
  def update_savefile_selection
    return on_savefile_ok     if Input.trigger?(:C)
    return on_savefile_cancel if Input.trigger?(:B)
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ● セーブファイル［決定］
  #--------------------------------------------------------------------------
  def on_savefile_ok
  end
  #--------------------------------------------------------------------------
  # ● セーブファイル［キャンセル］
  #--------------------------------------------------------------------------
  def on_savefile_cancel
    Sound.play_cancel
    return_scene
  end
  #--------------------------------------------------------------------------
  # ● カーソルの更新
  #--------------------------------------------------------------------------
  def update_cursor
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_pagedown   if Input.trigger?(:R)
    cursor_pageup     if Input.trigger?(:L)
    if @index != last_index
      Sound.play_cursor
      @savefile_windows[last_index].selected = false
      @savefile_windows[@index].selected = true
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソルを下に移動
  #--------------------------------------------------------------------------
  def cursor_down(wrap)
    @index = (@index + 1) % item_max if @index < item_max - 1 || wrap
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # ● カーソルを上に移動
  #--------------------------------------------------------------------------
  def cursor_up(wrap)
    @index = (@index - 1 + item_max) % item_max if @index > 0 || wrap
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ後ろに移動
  #--------------------------------------------------------------------------
  def cursor_pagedown
    if top_index + visible_max < item_max
      self.top_index += visible_max
      @index = [@index + visible_max, item_max - 1].min
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ前に移動
  #--------------------------------------------------------------------------
  def cursor_pageup
    if top_index > 0
      self.top_index -= visible_max
      @index = [@index - visible_max, 0].max
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置が画面内になるようにスクロール
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_index = index if index < top_index
    self.bottom_index = index if index > bottom_index
  end
end
