# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2012 - 2016 - MIT License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Jekyll::Assets::Liquid::Filters do
  let :site do
    stub_jekyll_site
  end

  let :renderer do
    Renderer.new site
  end

  #

  [
    %w(img ruby.png), %w(image ruby.png),
    %w(js bundle),    %w(javascript bundle),
    %w(css bundle),   %w(stylesheet bundle),
    %w(style bundle), %w(asset_path bundle.css)
  ].each do |name, *args|
    context "#{name} filter" do
      subject do
        renderer.filter(name, *args)
      end

      it "matches the #{name} tag" do
        is_expected.to eq renderer.tag(name, *args)
      end
    end
  end

  class Renderer
    include Jekyll::Assets::Liquid::Filters

    def initialize(site)
      @site = site
      @sprockets = Jekyll::Assets::Env.new(@site)
      @context = Liquid::Context.new({}, {}, { :site => @site, :sprockets => @sprockets })
    end

    def filter(name, *args)
      public_send name, *args
    end

    def tag(name, *args)
      Jekyll::Assets::Liquid::Tag.send(:new, name, *args, []).render(@context)
    end
  end

  context "fixture site" do
    before :each do
      site.process
    end

    #

    it "uses tags and returns the HTML" do
      expect(fragment(site.pages.first.to_s).xpath("p//img[contains(@alt, 'filter')]").size).to(
        eq 1
      )
    end
  end
end
