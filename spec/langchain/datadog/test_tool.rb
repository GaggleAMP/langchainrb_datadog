# frozen_string_literal: true

class TestTool
  extend Langchain::ToolDefinition

  def invoke = 'success'
end
