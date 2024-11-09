#==============================================================================
# ■ Window_BattleEnemy
#------------------------------------------------------------------------------
# 　バトル画面で、行動対象の敵キャラを選択するウィンドウです。
#==============================================================================

class Window_BattleEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     info_viewport : 情報表示用ビューポート
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
    super(0, info_viewport.rect.y, window_width, fitting_height(4))
    refresh
    self.visible = false
    @info_viewport = info_viewport
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 128
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    $game_troop.alive_members.size
  end
  #--------------------------------------------------------------------------
  # ● 敵キャラオブジェクト取得
  #--------------------------------------------------------------------------
  def enemy
    $game_troop.alive_members[@index]
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color)
    name = $game_troop.alive_members[index].name
    draw_text(item_rect_for_text(index), name)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの表示
  #--------------------------------------------------------------------------
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.x = width_remain
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの非表示
  #--------------------------------------------------------------------------
  def hide
    @info_viewport.rect.width = Graphics.width if @info_viewport
    super
  end
end
