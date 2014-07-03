
# exp_song
require 'mongo'
require 'mysql2'
# @cyy = Mysql2::Client.new(:host => "10.0.0.9", :username => "cyy", :password => '123', :database => 'db_ttus', :reconnect => true)
@msql = Mysql2::Client.new socket: '/var/lib/mysql/mysql.sock', username: 'root', password: 'js@mysql', database: 'db_final_music', reconnect: true
@msql2 = Mysql2::Client.new socket: '/var/lib/mysql/mysql.sock', username: 'root', password: 'js@mysql', database: 'db_final_music', reconnect: true
# @mg = Mongo::ReplSetConnection.new(['10.0.0.4:10006','10.0.0.5:10006', '10.0.0.12:10006'], safe:false, :read => :primary).db("ttus")
@mg = Mongo::MongoClient.new('/tmp/mongodb-27017.sock').db('ttpod_search')

module MyFix
  refine String do
    def blank?
      strip.empty? ? true : false
    end
  end
end

using MyFix

def c2ms str
  a = str.strip.split(':')
  (a[0].to_i * 60 + a[1].to_i) * 1000
end

#cdn_config
i,j = 0, 0
buf = []
@mg[:cdn_config].drop
qstr = "select * from cdn_config"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  h['download'] = (h['download'] + ' ' + h.delete('ting')).split(' ').uniq
  h['enabled'] = h['enabled'] == 1 ? true : false
  buf << h
end and nil
@mg[:cdn_config].insert(buf) #and nil unless buf.empty?

#dict
i,j = 0, 0
buf.clear
qstr = "select * from dict"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  type = []
  type << :singer if h['is_singer'] == 1
  type << :song if h['is_song'] == 1
  type << :singer_alise if h['is_singer_alias'] == 1
  type << :mv if h['is_mv'] == 1
  ['is_song', 'is_singer', 'is_mv', 'is_singer_alias'].each {|k| h.delete k}
  h[:type] = type
  h['enabled'] = h['enabled'] == 1 ? true : false
  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:dict].insert(buf)
    buf.clear
  end
end and nil
@mg[:dict].insert(buf) and nil unless buf.empty?

#eq_config
i,j = 0, 0
buf.clear
@mg[:eq_config].drop
qstr = "select * from eq_config"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  h['eq'] = [h['eq'].split(',').map(&:to_i)]
  h['reverbed'] = h['reverbed'] == 1 ? true : false
  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:eq_config].insert(buf)
    buf.clear
  end
end and nil
@mg[:eq_config].insert(buf) and nil unless buf.empty?

#mv_resources
# i,j = 0, 0
# buf.clear
# @mg[:mv_resources].drop
# qstr = "select * from mv_resources"
# @msql.query(qstr, stream: true, cache_rows: false).each do |h|
#   printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
#   qstr2 = "select duration, path, bit_rate, size, suffix from video_download where video_id = #{h['_id']}"
#   @msql2.query(qstr2, stream: true, cache_rows: false).each do |c|
#     unless c['duration'].nil? or c['duration'].blank?
#       c['duration'] = c2ms(c['duration'])
#       (h[:down_list] ||= []) << c
#     end
#   end
#   buf << h
#   if i % 1000 == 0
#     printf "%-10s|%20s|%-20s\r", 'wr', i, j
#     @mg[:mv_resources].insert(buf)
#     buf.clear
#   end
# end and nil
# @mg[:mv_resources].insert(buf) and nil unless buf.empty?

#song_adwords
i,j = 0, 0
buf.clear
qstr = "select * from song_adwords"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  h['include'].nil? or h['include'].empty? ? h.delete('include') : h['include'] = h['include'].split(',').map(&:to_i)
  h['exclude'].nil? or h['exclude'].empty? ? h.delete('exclude') : h['exclude'] = h['exclude'].split(',').map(&:to_i)
  h['enabled'] = h['enabled'] == 1 ? true : false
  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:song_adwords].insert(buf)
    buf.clear
  end
end and nil
@mg[:song_adwords].insert(buf) and nil unless buf.empty?

#song_blacklist
i,j = 0, 0
buf.clear
qstr = "select * from song_blacklist"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  h.delete('desc') if h['desc'].blank?
  h['enabled'] = h['enabled'] == 1 ? true : false
  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:song_blacklist].insert(buf)
    buf.clear
  end
end and nil
@mg[:song_blacklist].insert(buf) and nil unless buf.empty?

#song_hot_search
i,j = 0, 0
buf.clear
qstr = "select * from song_hot_search"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:song_hot_search].insert(buf)
    buf.clear
  end
end and nil
@mg[:song_hot_search].insert(buf) and nil unless buf.empty?

#song_queryfield
i,j = 0, 0
buf.clear
qstr = "select * from song_queryfield"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  h.delete('desc') if h['desc'].nil? or h['desc'].empty?
  h['enabled'] = h['enabled'] == 1 ? true : false
  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:song_queryfield].insert(buf)
    buf.clear
  end
end and nil
@mg[:song_queryfield].insert(buf) and nil unless buf.empty?

#song_weight
i,j = 0, 0
buf.clear
qstr = "select * from song_weight"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  h.delete('desc') if h['desc'].nil? or h['desc'].empty?
  h['enabled'] = h['enabled'] == 1 ? true : false
  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:song_weight].insert(buf)
    buf.clear
  end
end and nil
@mg[:song_weight].insert(buf) and nil unless buf.empty?

#songs
i,j = 0, 0
buf.clear
@mg[:songs].drop
qstr = "select * from songs"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j

  h.delete('album_name') if h['album_name'].nil? or h['album_name'].blank?

  if h['genre'].nil? or h['genre'].blank?
    h.delete('genre')
  else
    h['genre'] = h['genre'].strip.split(',')
  end

  if h['tags'].nil? or h['tags'].blank?
    h.delete('tags')
  else
    h['tags'] = h['tags'].strip.split(',')
  end
  h[:singer] = {id: h.delete('singer_id'), name: h.delete('singer_name')}

  qstr2 = "select duration, path, bit_rate, size, suffix from song_download where song_id = #{h['_id']}"
  @msql2.query(qstr2, stream: true, cache_rows: false).each do |c|
    unless c['duration'].nil? or c['duration'].blank?
      c['duration'] = c2ms(c['duration'])
      (h[:down_list] ||= []) << c
    end
  end

  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:songs].insert(buf)
    buf.clear
  end
end and nil
@mg[:songs].insert(buf) and nil unless buf.empty?

#videos
i,j = 0, 0
buf.clear
@mg[:videos].drop
qstr = "select * from videos"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j

  qstr2 = "select duration, path, bit_rate, size, suffix from video_download where video_id = #{h['_id']}"
  @msql2.query(qstr2, stream: true, cache_rows: false).each do |c|
    unless c['duration'].nil? or c['duration'].blank?
      c['duration'] = c2ms(c['duration'])
      (h[:down_list] ||= []) << c
    end
  end

  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:videos].insert(buf)
    buf.clear
  end
end and nil
@mg[:videos].insert(buf) and nil unless buf.empty?

#singers
i,j = 0, 0
buf.clear
qstr = "select * from view_singers"
@msql.query(qstr, stream: true, cache_rows: false).each do |h|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j

  buf << h
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:singers].insert(buf)
    buf.clear
  end
end and nil
@mg[:singers].insert(buf) and nil unless buf.empty?



@mg[:users].ensure_index [[:user_name, Mongo::ASCENDING], [:password, Mongo::DESCENDING]]
@mg[:users].ensure_index [[:nick_name, Mongo::ASCENDING]]#, unique:true#, drop_dups:true
@mg[:users].ensure_index [[:access_token, Mongo::ASCENDING]]
@mg[:users].ensure_index [['via', Mongo::ASCENDING], ['third.access_token', Mongo::ASCENDING]]#, unique:true, drop_dups:true
@mg[:users].ensure_index [['via', Mongo::ASCENDING], ['third.openid', Mongo::ASCENDING]]#, unique:true, drop_dups:true
#@cyy[:users].ensure_index [['third.openid', Mongo::ASCENDING]], unique:true, drop_dups:true




# @mg = Mongo::ReplSetConnection.new(['10.0.0.4:10005','10.0.0.5:10005', '10.0.0.12:10005'],:read => :secondary, safe:false).db("tt_fav_rs")
# @mg =  Mongo::Connection.new('10.0.0.4', 10005).db("tt_fav_jsrs")

# {"songList"=>[{"songId"=>994988, "songName"=>"当你听我说", "singerName"=>"胡夏", "peakTime"=>1344601333977}], "ttid"=>"3fa309d8e101b8dc2"}
# cl = Mongo::Connection.new('117.135.151.116',22003).db("db_user_song")['userSong']
# @mg = Mongo::Connection.new.db('tt_fav8')
# @cl = Mongo::Connection.new('117.135.151.116',27018).db("db_user_song")['userSong']
# @mg = Mongo::Connection.new('10.0.0.4',10005).db("tt_fav_rs")

# ------- convert cl mongo picks
require 'mongo'
@mg = Mongo::ReplSetConnection.new(['10.0.0.4:10005','10.0.0.5:10005', '10.0.0.12:10005'], safe:false, :read => :primary).db("tt_fav_jsrs3")
@cl = Mongo::Connection.new('117.135.151.116',27018).db("db_user_song")['userSong']
i,j = 0, @cl.count
buf.clear
@cl.find.each do |doc|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  _uid =  doc['openId'] || 0
  # @mg[:users].save _id: _uid
  doc['songList'].each do |d|
    _sid = d['songId'] || 0
    buf << {_id: "%s|%s" % [_uid, _sid],  user_id: _uid, song_id: _sid, pick_time: (d['peakTime'] || 0) / 1000}
    if i % 1000 == 0
      printf "%-10s|%20s|%-20s\r", 'wr', i, j
      @mg[:picks].insert(buf)
      buf.clear
    end
  end
end and nil
@mg[:picks].insert(buf) and nil unless buf.empty?
buf.clear

_tarr = @mg[:picks].distinct(:song_id) - @mg[:songs].distinct(:_id)
@mg[:picks].remove(song_id: {'$in' => _tarr}) unless _tarr.empty?

@mg[:picks].ensure_index [[:user_id, Mongo::ASCENDING], [:pick_time, Mongo::DESCENDING]]#, background: true
@mg[:picks].ensure_index [[:song_id, Mongo::ASCENDING], [:user_id, Mongo::ASCENDING]]#, background: true

# ------- fix cl mongo data -2 ---usrs after picks
require 'mongo'
@mg = Mongo::ReplSetConnection.new(['10.0.0.4:10005','10.0.0.5:10005', '10.0.0.12:10005'], safe:false, :read => :primary).db("tt_fav_jsrs3")
_uids = @mg[:picks].distinct(:user_id) and nil
i,j = 0,_uids.count
buf.clear
_uids.each do |_uid|
  printf "%-10s|%20s|%-20s\r", 'rd', i += 1, j
  _pick_count = @mg[:picks].count query: {user_id: _uid}
  _last_pick_time = @mg[:picks].find_one({user_id: _uid}, sort:[[:pick_time, :desc]], limit:1)['pick_time'] || 0
  buf << {_id: _uid, pick_count: _pick_count, last_pick_time: _last_pick_time}
  if i % 1000 == 0
    printf "%-10s|%20s|%-20s\r", 'wr', i, j
    @mg[:users].insert(buf)
    buf.clear
  end
end and nil
@mg[:users].insert(buf) and nil unless buf.empty?
buf.clear

# ------- fix cl mongo data -1 songs after hww & picks
require 'mongo'
@mg = Mongo::ReplSetConnection.new(['10.0.0.4:10005','10.0.0.5:10005', '10.0.0.12:10005'], safe:false, :read => :primary).db("tt_fav_jsrs3")
_sids = @mg[:picks].distinct(:song_id) and nil
i,j = 0, _sids.count
_sids.each do |_sid|
  _pick_count = @mg[:picks].count query: {song_id: _sid}
  _last_pick_time = @mg[:picks].find_one({song_id: _sid}, sort:[[:pick_time, :desc]], limit:1)['pick_time'] || 0
  @mg[:songs].update({_id: _sid}, {'$set' => {pick_count: _pick_count, last_pick_time: _last_pick_time}})
  printf "%20s/%-10s\r", i += 1, j
end and nil


# ------- fix cl mongo data -3 build index after users & songs
@mg[:users].ensure_index [[:pick_count, Mongo::DESCENDING]]#, background: true
@mg[:songs].ensure_index [[:last_pick_time, Mongo::DESCENDING]]#, background: true


require 'mongo'
@mg = Mongo::ReplSetConnection.new(['10.0.0.4:10006','10.0.0.5:10006'], safe:false, :read => :primary).db("ttus")
@mg[:users].update({via: 'qq'}, {'$rename' =>{'third' => 'qq'}}, multi:true)
@mg[:users].update({via: 'sina'}, {'$rename' =>{'third' => 'sina'}}, multi:true)
@mg[:users].ensure_index [['qq.openid', Mongo::ASCENDING]]
@mg[:users].ensure_index [['qq.access_token', Mongo::ASCENDING]]
@mg[:users].ensure_index [['sina.openid', Mongo::ASCENDING]]








