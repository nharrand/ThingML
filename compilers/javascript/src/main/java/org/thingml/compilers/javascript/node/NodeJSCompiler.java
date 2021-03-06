/**
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * See the NOTICE file distributed with this work for additional
 * information regarding copyright ownership.
 */
package org.thingml.compilers.javascript.node;

import org.thingml.compilers.Context;
import org.thingml.compilers.ThingMLCompiler;
import org.thingml.compilers.javascript.JSCompiler;
import org.thingml.compilers.javascript.JSThingApiCompiler;
import org.thingml.xtext.thingML.Configuration;
import org.thingml.xtext.thingML.ThingMLModel;

public class NodeJSCompiler extends JSCompiler {

	public NodeJSCompiler() {
		super(
			new NodeJSThingActionCompiler(),
			new JSThingApiCompiler(),
			new NodeJSCfgMainGenerator(),
			new NodeJSCfgBuildCompiler(),
			new NodeJSThingImplCompiler()
		);
	}

	@Override
	public ThingMLCompiler clone() {
		return new NodeJSCompiler();
	}

	@Override
	public String getID() {
		return "nodejs";
	}

	@Override
	public String getName() {
		return "Javascript for NodeJS";
	}

	@Override
	public String getDescription() {
		return "Generates Javascript code for the NodeJS platform.";
	}

	@Override
    public String getDockerBaseImage(Configuration cfg, Context ctx) {
        return "node:alpine";
    }

    @Override
    public String getDockerCMD(Configuration cfg, Context ctx) {
        return "node\", \"main.js"; //Param main.js
    }

    @Override
    public String getDockerCfgRunPath(Configuration cfg, Context ctx) {
        return "RUN npm install state.js@5.11.0\n" +
						"FROM node:alpine\n" +
						"COPY --from=0 /node_modules .\n" +
						"COPY package.json package.json\n" +
        		"RUN npm install --production\n" +
        		"COPY . .\n";
    }

	@Override
	protected String getEnumPath(Configuration t, ThingMLModel model, Context ctx) {
		return "enums.js";
	}
}
