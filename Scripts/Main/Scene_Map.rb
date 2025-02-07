#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    SceneManager.clear
    $game_player.straighten
    $game_map.refresh
    $game_message.visible = false
    create_spriteset
    create_all_windows
    @menu_calling = false
  end
  #--------------------------------------------------------------------------
  # ● トランジション実行
  #    戦闘後やロード直後など、画面が暗転しているときはフェードインを行う。
  #--------------------------------------------------------------------------
  def perform_transition
    if Graphics.brightness == 0
      Graphics.transition(0)
      fadein(fadein_speed)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● トランジション速度の取得
  #--------------------------------------------------------------------------
  def transition_speed
    return 15
  end
  #--------------------------------------------------------------------------
  # ● 終了前処理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    pre_battle_scene if SceneManager.scene_is?(Scene_Battle)
    pre_title_scene  if SceneManager.scene_is?(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_spriteset
    perform_battle_transition if SceneManager.scene_is?(Scene_Battle)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    $game_map.update(true)
    $game_player.update
    $game_timer.update
    @spriteset.update
    update_scene if scene_change_ok?
  end
  #--------------------------------------------------------------------------
  # ● シーン遷移の可能判定
  #--------------------------------------------------------------------------
  def scene_change_ok?
    !$game_message.busy? && !$game_message.visible
  end
  #--------------------------------------------------------------------------
  # ● シーン遷移に関連する更新
  #--------------------------------------------------------------------------
  def update_scene
    check_gameover
    update_transfer_player unless scene_changing?
    update_encounter unless scene_changing?
    update_call_menu unless scene_changing?
    update_call_debug unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新（フェード用）
  #--------------------------------------------------------------------------
  def update_for_fade
    update_basic
    $game_map.update(false)
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 汎用フェード処理
  #--------------------------------------------------------------------------
  def fade_loop(duration)
    duration.times do |i|
      yield 255 * (i + 1) / duration
      update_for_fade
    end
  end
  #--------------------------------------------------------------------------
  # ● 画面のフェードイン
  #--------------------------------------------------------------------------
  def fadein(duration)
    fade_loop(duration) {|v| Graphics.brightness = v }
  end
  #--------------------------------------------------------------------------
  # ● 画面のフェードアウト
  #--------------------------------------------------------------------------
  def fadeout(duration)
    fade_loop(duration) {|v| Graphics.brightness = 255 - v }
  end
  #--------------------------------------------------------------------------
  # ● 画面のフェードイン（白）
  #--------------------------------------------------------------------------
  def white_fadein(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, 255 - v) }
  end
  #--------------------------------------------------------------------------
  # ● 画面のフェードアウト（白）
  #--------------------------------------------------------------------------
  def white_fadeout(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, v) }
  end
  #--------------------------------------------------------------------------
  # ● スプライトセットの作成
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Map.new
  end
  #--------------------------------------------------------------------------
  # ● スプライトセットの解放
  #--------------------------------------------------------------------------
  def dispose_spriteset
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    create_scroll_text_window
    create_location_window
  end
  #--------------------------------------------------------------------------
  # ● メッセージウィンドウの作成
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # ● スクロール文章ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_scroll_text_window
    @scroll_text_window = Window_ScrollText.new
  end
  #--------------------------------------------------------------------------
  # ● マップ名ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_location_window
    @map_name_window = Window_MapName.new
  end
  #--------------------------------------------------------------------------
  # ● 場所移動の更新
  #--------------------------------------------------------------------------
  def update_transfer_player
    perform_transfer if $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # ● エンカウントの更新
  #--------------------------------------------------------------------------
  def update_encounter
    SceneManager.call(Scene_Battle) if $game_player.encounter
  end
  #--------------------------------------------------------------------------
  # ● キャンセルボタンによるメニュー呼び出し判定
  #--------------------------------------------------------------------------
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      @menu_calling ||= Input.trigger?(:B)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
  #--------------------------------------------------------------------------
  # ● メニュー画面の呼び出し
  #--------------------------------------------------------------------------
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
  end
  #--------------------------------------------------------------------------
  # ● F9 キーによるデバッグ呼び出し判定
  #--------------------------------------------------------------------------
  def update_call_debug
    SceneManager.call(Scene_Debug) if $TEST && Input.press?(:F9)
  end
  #--------------------------------------------------------------------------
  # ● 場所移動の処理
  #--------------------------------------------------------------------------
  def perform_transfer
    pre_transfer
    $game_player.perform_transfer
    post_transfer
  end
  #--------------------------------------------------------------------------
  # ● 場所移動前の処理
  #--------------------------------------------------------------------------
  def pre_transfer
    @map_name_window.close
    case $game_temp.fade_type
    when 0
      fadeout(fadeout_speed)
    when 1
      white_fadeout(fadeout_speed)
    end
  end
  #--------------------------------------------------------------------------
  # ● 場所移動後の処理
  #--------------------------------------------------------------------------
  def post_transfer
    case $game_temp.fade_type
    when 0
      Graphics.wait(fadein_speed / 2)
      fadein(fadein_speed)
    when 1
      Graphics.wait(fadein_speed / 2)
      white_fadein(fadein_speed)
    end
    @map_name_window.open
  end
  #--------------------------------------------------------------------------
  # ● バトル画面遷移の前処理
  #--------------------------------------------------------------------------
  def pre_battle_scene
    Graphics.update
    Graphics.freeze
    @spriteset.dispose_characters
    BattleManager.save_bgm_and_bgs
    BattleManager.play_battle_bgm
    Sound.play_battle_start
  end
  #--------------------------------------------------------------------------
  # ● タイトル画面遷移の前処理
  #--------------------------------------------------------------------------
  def pre_title_scene
    fadeout(fadeout_speed_to_title)
  end
  #--------------------------------------------------------------------------
  # ● 戦闘前トランジション実行
  #--------------------------------------------------------------------------
  def perform_battle_transition
    Graphics.transition(60, "Graphics/System/BattleStart", 100)
    Graphics.freeze
  end
  #--------------------------------------------------------------------------
  # ● フェードアウト速度の取得
  #--------------------------------------------------------------------------
  def fadeout_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● フェードイン速度の取得
  #--------------------------------------------------------------------------
  def fadein_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● タイトル画面遷移用フェードアウト速度の取得
  #--------------------------------------------------------------------------
  def fadeout_speed_to_title
    return 60
  end
end
