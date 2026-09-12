# frozen_string_literal: true

# camaleon_cms reads each gem plugin's config/camaleon_plugin.json with JSON.parse while the engine
# boots. json 3 rejects comments by default, so a comment in the file stops every host app that
# resolves json 3 from booting. The suite runs on json 2, so parse the file as json 3 would.
RSpec.describe CamaMetaTag::Engine do
  describe 'config/camaleon_plugin.json' do
    let(:config) { described_class.root.join('config/camaleon_plugin.json').read }

    it 'is plain JSON, without comments' do
      expect { JSON.parse(config, allow_comments: false) }.not_to raise_error
    end
  end
end
