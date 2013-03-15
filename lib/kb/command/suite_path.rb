# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'kb/thor'

module KB

  module Command

    # Suite path command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class SuitePath < KB::Thor::BaseGroup

      argument :suite_name, :required => false

      def path
        say suite_path(suite_name)
      end
    end
  end
end
