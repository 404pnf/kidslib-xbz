require 'pp'
require 'fileutils'
f = Dir['*']
ff = f.select { |e| e =~ /_[0-9]\.jpg/ && e.size > 12 }
      .map { |e| [e, e.sub(/_[0-9]\.jpg/, '.jpg')] }
pp ff
#g = f.select { |e| e =~ /'/ or e =~ / / }
#      .map { |e| [e, e.gsub(/[' ]/, '_')] }
#pp g

gg = f.select { |e| e =~ /\.mp3$/ }
      .map do  |e| 
	ee = e.gsub(/xbz/, '')
	ee = ee[0..1] + '_' + ee[2..-1]
	[e, ee]
	end
pp gg
#ff.each { |(old, new)| FileUtils.mv(old, new, :verbose => true, :noop => true) }
#ff.each { |(old, new)| FileUtils.mv(old, new, :verbose => true) }
#g.each { |(old, new)| FileUtils.mv(old, new, :verbose => true) }
gg.each { |(old, new)| FileUtils.mv(old, new, :verbose => true) }
