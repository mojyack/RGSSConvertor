#==============================================================================
# ■ Main
#------------------------------------------------------------------------------
# 　モジュールとクラスの定義が終わった後に実行される処理です。
#==============================================================================

rgss_main {
  rvdata_to_text("/tmp/Scripts.rvdata2", "/tmp")
  text_to_rvdata("/tmp/Scripts.txt", "/tmp/Scripts.rvdata2")
}
