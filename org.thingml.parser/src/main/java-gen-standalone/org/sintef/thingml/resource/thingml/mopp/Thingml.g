grammar Thingml;

options {
	superClass = ThingmlANTLRParserBase;
	backtrack = true;
	memoize = true;
}

@lexer::header {
	package org.sintef.thingml.resource.thingml.mopp;
}

@lexer::members {
	public java.util.List<org.antlr.runtime3_4_0.RecognitionException> lexerExceptions  = new java.util.ArrayList<org.antlr.runtime3_4_0.RecognitionException>();
	public java.util.List<Integer> lexerExceptionsPosition = new java.util.ArrayList<Integer>();
	
	public void reportError(org.antlr.runtime3_4_0.RecognitionException e) {
		lexerExceptions.add(e);
		lexerExceptionsPosition.add(((org.antlr.runtime3_4_0.ANTLRStringStream) input).index());
	}
}
@header{
	package org.sintef.thingml.resource.thingml.mopp;
}

@members{
	private org.sintef.thingml.resource.thingml.IThingmlTokenResolverFactory tokenResolverFactory = new org.sintef.thingml.resource.thingml.mopp.ThingmlTokenResolverFactory();
	
	/**
	 * the index of the last token that was handled by collectHiddenTokens()
	 */
	private int lastPosition;
	
	/**
	 * A flag that indicates whether the parser should remember all expected elements.
	 * This flag is set to true when using the parse for code completion. Otherwise it
	 * is set to false.
	 */
	private boolean rememberExpectedElements = false;
	
	private Object parseToIndexTypeObject;
	private int lastTokenIndex = 0;
	
	/**
	 * A list of expected elements the were collected while parsing the input stream.
	 * This list is only filled if <code>rememberExpectedElements</code> is set to
	 * true.
	 */
	private java.util.List<org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal> expectedElements = new java.util.ArrayList<org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal>();
	
	private int mismatchedTokenRecoveryTries = 0;
	/**
	 * A helper list to allow a lexer to pass errors to its parser
	 */
	protected java.util.List<org.antlr.runtime3_4_0.RecognitionException> lexerExceptions = java.util.Collections.synchronizedList(new java.util.ArrayList<org.antlr.runtime3_4_0.RecognitionException>());
	
	/**
	 * Another helper list to allow a lexer to pass positions of errors to its parser
	 */
	protected java.util.List<Integer> lexerExceptionsPosition = java.util.Collections.synchronizedList(new java.util.ArrayList<Integer>());
	
	/**
	 * A stack for incomplete objects. This stack is used filled when the parser is
	 * used for code completion. Whenever the parser starts to read an object it is
	 * pushed on the stack. Once the element was parser completely it is popped from
	 * the stack.
	 */
	java.util.List<org.eclipse.emf.ecore.EObject> incompleteObjects = new java.util.ArrayList<org.eclipse.emf.ecore.EObject>();
	
	private int stopIncludingHiddenTokens;
	private int stopExcludingHiddenTokens;
	private int tokenIndexOfLastCompleteElement;
	
	private int expectedElementsIndexOfLastCompleteElement;
	
	/**
	 * The offset indicating the cursor position when the parser is used for code
	 * completion by calling parseToExpectedElements().
	 */
	private int cursorOffset;
	
	/**
	 * The offset of the first hidden token of the last expected element. This offset
	 * is used to discard expected elements, which are not needed for code completion.
	 */
	private int lastStartIncludingHidden;
	
	protected void addErrorToResource(final String errorMessage, final int column, final int line, final int startIndex, final int stopIndex) {
		postParseCommands.add(new org.sintef.thingml.resource.thingml.IThingmlCommand<org.sintef.thingml.resource.thingml.IThingmlTextResource>() {
			public boolean execute(org.sintef.thingml.resource.thingml.IThingmlTextResource resource) {
				if (resource == null) {
					// the resource can be null if the parser is used for code completion
					return true;
				}
				resource.addProblem(new org.sintef.thingml.resource.thingml.IThingmlProblem() {
					public org.sintef.thingml.resource.thingml.ThingmlEProblemSeverity getSeverity() {
						return org.sintef.thingml.resource.thingml.ThingmlEProblemSeverity.ERROR;
					}
					public org.sintef.thingml.resource.thingml.ThingmlEProblemType getType() {
						return org.sintef.thingml.resource.thingml.ThingmlEProblemType.SYNTAX_ERROR;
					}
					public String getMessage() {
						return errorMessage;
					}
					public java.util.Collection<org.sintef.thingml.resource.thingml.IThingmlQuickFix> getQuickFixes() {
						return null;
					}
				}, column, line, startIndex, stopIndex);
				return true;
			}
		});
	}
	
	public void addExpectedElement(org.eclipse.emf.ecore.EClass eClass, int[] ids) {
		if (!this.rememberExpectedElements) {
			return;
		}
		int terminalID = ids[0];
		int followSetID = ids[1];
		org.sintef.thingml.resource.thingml.IThingmlExpectedElement terminal = org.sintef.thingml.resource.thingml.grammar.ThingmlFollowSetProvider.TERMINALS[terminalID];
		org.sintef.thingml.resource.thingml.mopp.ThingmlContainedFeature[] containmentFeatures = new org.sintef.thingml.resource.thingml.mopp.ThingmlContainedFeature[ids.length - 2];
		for (int i = 2; i < ids.length; i++) {
			containmentFeatures[i - 2] = org.sintef.thingml.resource.thingml.grammar.ThingmlFollowSetProvider.LINKS[ids[i]];
		}
		org.sintef.thingml.resource.thingml.grammar.ThingmlContainmentTrace containmentTrace = new org.sintef.thingml.resource.thingml.grammar.ThingmlContainmentTrace(eClass, containmentFeatures);
		org.eclipse.emf.ecore.EObject container = getLastIncompleteElement();
		org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal expectedElement = new org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal(container, terminal, followSetID, containmentTrace);
		setPosition(expectedElement, input.index());
		int startIncludingHiddenTokens = expectedElement.getStartIncludingHiddenTokens();
		if (lastStartIncludingHidden >= 0 && lastStartIncludingHidden < startIncludingHiddenTokens && cursorOffset > startIncludingHiddenTokens) {
			// clear list of expected elements
			this.expectedElements.clear();
			this.expectedElementsIndexOfLastCompleteElement = 0;
		}
		lastStartIncludingHidden = startIncludingHiddenTokens;
		this.expectedElements.add(expectedElement);
	}
	
	protected void collectHiddenTokens(org.eclipse.emf.ecore.EObject element) {
	}
	
	protected void copyLocalizationInfos(final org.eclipse.emf.ecore.EObject source, final org.eclipse.emf.ecore.EObject target) {
		if (disableLocationMap) {
			return;
		}
		postParseCommands.add(new org.sintef.thingml.resource.thingml.IThingmlCommand<org.sintef.thingml.resource.thingml.IThingmlTextResource>() {
			public boolean execute(org.sintef.thingml.resource.thingml.IThingmlTextResource resource) {
				org.sintef.thingml.resource.thingml.IThingmlLocationMap locationMap = resource.getLocationMap();
				if (locationMap == null) {
					// the locationMap can be null if the parser is used for code completion
					return true;
				}
				locationMap.setCharStart(target, locationMap.getCharStart(source));
				locationMap.setCharEnd(target, locationMap.getCharEnd(source));
				locationMap.setColumn(target, locationMap.getColumn(source));
				locationMap.setLine(target, locationMap.getLine(source));
				return true;
			}
		});
	}
	
	protected void copyLocalizationInfos(final org.antlr.runtime3_4_0.CommonToken source, final org.eclipse.emf.ecore.EObject target) {
		if (disableLocationMap) {
			return;
		}
		postParseCommands.add(new org.sintef.thingml.resource.thingml.IThingmlCommand<org.sintef.thingml.resource.thingml.IThingmlTextResource>() {
			public boolean execute(org.sintef.thingml.resource.thingml.IThingmlTextResource resource) {
				org.sintef.thingml.resource.thingml.IThingmlLocationMap locationMap = resource.getLocationMap();
				if (locationMap == null) {
					// the locationMap can be null if the parser is used for code completion
					return true;
				}
				if (source == null) {
					return true;
				}
				locationMap.setCharStart(target, source.getStartIndex());
				locationMap.setCharEnd(target, source.getStopIndex());
				locationMap.setColumn(target, source.getCharPositionInLine());
				locationMap.setLine(target, source.getLine());
				return true;
			}
		});
	}
	
	/**
	 * Sets the end character index and the last line for the given object in the
	 * location map.
	 */
	protected void setLocalizationEnd(java.util.Collection<org.sintef.thingml.resource.thingml.IThingmlCommand<org.sintef.thingml.resource.thingml.IThingmlTextResource>> postParseCommands , final org.eclipse.emf.ecore.EObject object, final int endChar, final int endLine) {
		if (disableLocationMap) {
			return;
		}
		postParseCommands.add(new org.sintef.thingml.resource.thingml.IThingmlCommand<org.sintef.thingml.resource.thingml.IThingmlTextResource>() {
			public boolean execute(org.sintef.thingml.resource.thingml.IThingmlTextResource resource) {
				org.sintef.thingml.resource.thingml.IThingmlLocationMap locationMap = resource.getLocationMap();
				if (locationMap == null) {
					// the locationMap can be null if the parser is used for code completion
					return true;
				}
				locationMap.setCharEnd(object, endChar);
				locationMap.setLine(object, endLine);
				return true;
			}
		});
	}
	
	public org.sintef.thingml.resource.thingml.IThingmlTextParser createInstance(java.io.InputStream actualInputStream, String encoding) {
		try {
			if (encoding == null) {
				return new ThingmlParser(new org.antlr.runtime3_4_0.CommonTokenStream(new ThingmlLexer(new org.antlr.runtime3_4_0.ANTLRInputStream(actualInputStream))));
			} else {
				return new ThingmlParser(new org.antlr.runtime3_4_0.CommonTokenStream(new ThingmlLexer(new org.antlr.runtime3_4_0.ANTLRInputStream(actualInputStream, encoding))));
			}
		} catch (java.io.IOException e) {
			new org.sintef.thingml.resource.thingml.util.ThingmlRuntimeUtil().logError("Error while creating parser.", e);
			return null;
		}
	}
	
	/**
	 * This default constructor is only used to call createInstance() on it.
	 */
	public ThingmlParser() {
		super(null);
	}
	
	protected org.eclipse.emf.ecore.EObject doParse() throws org.antlr.runtime3_4_0.RecognitionException {
		this.lastPosition = 0;
		// required because the lexer class can not be subclassed
		((ThingmlLexer) getTokenStream().getTokenSource()).lexerExceptions = lexerExceptions;
		((ThingmlLexer) getTokenStream().getTokenSource()).lexerExceptionsPosition = lexerExceptionsPosition;
		Object typeObject = getTypeObject();
		if (typeObject == null) {
			return start();
		} else if (typeObject instanceof org.eclipse.emf.ecore.EClass) {
			org.eclipse.emf.ecore.EClass type = (org.eclipse.emf.ecore.EClass) typeObject;
			if (type.getInstanceClass() == org.sintef.thingml.ThingMLModel.class) {
				return parse_org_sintef_thingml_ThingMLModel();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Message.class) {
				return parse_org_sintef_thingml_Message();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Function.class) {
				return parse_org_sintef_thingml_Function();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Thing.class) {
				return parse_org_sintef_thingml_Thing();
			}
			if (type.getInstanceClass() == org.sintef.thingml.RequiredPort.class) {
				return parse_org_sintef_thingml_RequiredPort();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ProvidedPort.class) {
				return parse_org_sintef_thingml_ProvidedPort();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Property.class) {
				return parse_org_sintef_thingml_Property();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Parameter.class) {
				return parse_org_sintef_thingml_Parameter();
			}
			if (type.getInstanceClass() == org.sintef.thingml.PrimitiveType.class) {
				return parse_org_sintef_thingml_PrimitiveType();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Enumeration.class) {
				return parse_org_sintef_thingml_Enumeration();
			}
			if (type.getInstanceClass() == org.sintef.thingml.EnumerationLiteral.class) {
				return parse_org_sintef_thingml_EnumerationLiteral();
			}
			if (type.getInstanceClass() == org.sintef.thingml.PlatformAnnotation.class) {
				return parse_org_sintef_thingml_PlatformAnnotation();
			}
			if (type.getInstanceClass() == org.sintef.thingml.StateMachine.class) {
				return parse_org_sintef_thingml_StateMachine();
			}
			if (type.getInstanceClass() == org.sintef.thingml.State.class) {
				return parse_org_sintef_thingml_State();
			}
			if (type.getInstanceClass() == org.sintef.thingml.CompositeState.class) {
				return parse_org_sintef_thingml_CompositeState();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ParallelRegion.class) {
				return parse_org_sintef_thingml_ParallelRegion();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Transition.class) {
				return parse_org_sintef_thingml_Transition();
			}
			if (type.getInstanceClass() == org.sintef.thingml.InternalTransition.class) {
				return parse_org_sintef_thingml_InternalTransition();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ReceiveMessage.class) {
				return parse_org_sintef_thingml_ReceiveMessage();
			}
			if (type.getInstanceClass() == org.sintef.thingml.PropertyAssign.class) {
				return parse_org_sintef_thingml_PropertyAssign();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Configuration.class) {
				return parse_org_sintef_thingml_Configuration();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ConfigInclude.class) {
				return parse_org_sintef_thingml_ConfigInclude();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Instance.class) {
				return parse_org_sintef_thingml_Instance();
			}
			if (type.getInstanceClass() == org.sintef.thingml.Connector.class) {
				return parse_org_sintef_thingml_Connector();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ConfigPropertyAssign.class) {
				return parse_org_sintef_thingml_ConfigPropertyAssign();
			}
			if (type.getInstanceClass() == org.sintef.thingml.InstanceRef.class) {
				return parse_org_sintef_thingml_InstanceRef();
			}
			if (type.getInstanceClass() == org.sintef.thingml.SendAction.class) {
				return parse_org_sintef_thingml_SendAction();
			}
			if (type.getInstanceClass() == org.sintef.thingml.VariableAssignment.class) {
				return parse_org_sintef_thingml_VariableAssignment();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ActionBlock.class) {
				return parse_org_sintef_thingml_ActionBlock();
			}
			if (type.getInstanceClass() == org.sintef.thingml.LocalVariable.class) {
				return parse_org_sintef_thingml_LocalVariable();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ExternStatement.class) {
				return parse_org_sintef_thingml_ExternStatement();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ConditionalAction.class) {
				return parse_org_sintef_thingml_ConditionalAction();
			}
			if (type.getInstanceClass() == org.sintef.thingml.LoopAction.class) {
				return parse_org_sintef_thingml_LoopAction();
			}
			if (type.getInstanceClass() == org.sintef.thingml.PrintAction.class) {
				return parse_org_sintef_thingml_PrintAction();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ErrorAction.class) {
				return parse_org_sintef_thingml_ErrorAction();
			}
			if (type.getInstanceClass() == org.sintef.thingml.ReturnAction.class) {
				return parse_org_sintef_thingml_ReturnAction();
			}
			if (type.getInstanceClass() == org.sintef.thingml.FunctionCallStatement.class) {
				return parse_org_sintef_thingml_FunctionCallStatement();
			}
		}
		throw new org.sintef.thingml.resource.thingml.mopp.ThingmlUnexpectedContentTypeException(typeObject);
	}
	
	public int getMismatchedTokenRecoveryTries() {
		return mismatchedTokenRecoveryTries;
	}
	
	public Object getMissingSymbol(org.antlr.runtime3_4_0.IntStream arg0, org.antlr.runtime3_4_0.RecognitionException arg1, int arg2, org.antlr.runtime3_4_0.BitSet arg3) {
		mismatchedTokenRecoveryTries++;
		return super.getMissingSymbol(arg0, arg1, arg2, arg3);
	}
	
	public Object getParseToIndexTypeObject() {
		return parseToIndexTypeObject;
	}
	
	protected Object getTypeObject() {
		Object typeObject = getParseToIndexTypeObject();
		if (typeObject != null) {
			return typeObject;
		}
		java.util.Map<?,?> options = getOptions();
		if (options != null) {
			typeObject = options.get(org.sintef.thingml.resource.thingml.IThingmlOptions.RESOURCE_CONTENT_TYPE);
		}
		return typeObject;
	}
	
	/**
	 * Implementation that calls {@link #doParse()} and handles the thrown
	 * RecognitionExceptions.
	 */
	public org.sintef.thingml.resource.thingml.IThingmlParseResult parse() {
		terminateParsing = false;
		postParseCommands = new java.util.ArrayList<org.sintef.thingml.resource.thingml.IThingmlCommand<org.sintef.thingml.resource.thingml.IThingmlTextResource>>();
		org.sintef.thingml.resource.thingml.mopp.ThingmlParseResult parseResult = new org.sintef.thingml.resource.thingml.mopp.ThingmlParseResult();
		try {
			org.eclipse.emf.ecore.EObject result =  doParse();
			if (lexerExceptions.isEmpty()) {
				parseResult.setRoot(result);
			}
		} catch (org.antlr.runtime3_4_0.RecognitionException re) {
			reportError(re);
		} catch (java.lang.IllegalArgumentException iae) {
			if ("The 'no null' constraint is violated".equals(iae.getMessage())) {
				// can be caused if a null is set on EMF models where not allowed. this will just
				// happen if other errors occurred before
			} else {
				iae.printStackTrace();
			}
		}
		for (org.antlr.runtime3_4_0.RecognitionException re : lexerExceptions) {
			reportLexicalError(re);
		}
		parseResult.getPostParseCommands().addAll(postParseCommands);
		return parseResult;
	}
	
	public java.util.List<org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal> parseToExpectedElements(org.eclipse.emf.ecore.EClass type, org.sintef.thingml.resource.thingml.IThingmlTextResource dummyResource, int cursorOffset) {
		this.rememberExpectedElements = true;
		this.parseToIndexTypeObject = type;
		this.cursorOffset = cursorOffset;
		this.lastStartIncludingHidden = -1;
		final org.antlr.runtime3_4_0.CommonTokenStream tokenStream = (org.antlr.runtime3_4_0.CommonTokenStream) getTokenStream();
		org.sintef.thingml.resource.thingml.IThingmlParseResult result = parse();
		for (org.eclipse.emf.ecore.EObject incompleteObject : incompleteObjects) {
			org.antlr.runtime3_4_0.Lexer lexer = (org.antlr.runtime3_4_0.Lexer) tokenStream.getTokenSource();
			int endChar = lexer.getCharIndex();
			int endLine = lexer.getLine();
			setLocalizationEnd(result.getPostParseCommands(), incompleteObject, endChar, endLine);
		}
		if (result != null) {
			org.eclipse.emf.ecore.EObject root = result.getRoot();
			if (root != null) {
				dummyResource.getContentsInternal().add(root);
			}
			for (org.sintef.thingml.resource.thingml.IThingmlCommand<org.sintef.thingml.resource.thingml.IThingmlTextResource> command : result.getPostParseCommands()) {
				command.execute(dummyResource);
			}
		}
		// remove all expected elements that were added after the last complete element
		expectedElements = expectedElements.subList(0, expectedElementsIndexOfLastCompleteElement + 1);
		int lastFollowSetID = expectedElements.get(expectedElementsIndexOfLastCompleteElement).getFollowSetID();
		java.util.Set<org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal> currentFollowSet = new java.util.LinkedHashSet<org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal>();
		java.util.List<org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal> newFollowSet = new java.util.ArrayList<org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal>();
		for (int i = expectedElementsIndexOfLastCompleteElement; i >= 0; i--) {
			org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal expectedElementI = expectedElements.get(i);
			if (expectedElementI.getFollowSetID() == lastFollowSetID) {
				currentFollowSet.add(expectedElementI);
			} else {
				break;
			}
		}
		int followSetID = 436;
		int i;
		for (i = tokenIndexOfLastCompleteElement; i < tokenStream.size(); i++) {
			org.antlr.runtime3_4_0.CommonToken nextToken = (org.antlr.runtime3_4_0.CommonToken) tokenStream.get(i);
			if (nextToken.getType() < 0) {
				break;
			}
			if (nextToken.getChannel() == 99) {
				// hidden tokens do not reduce the follow set
			} else {
				// now that we have found the next visible token the position for that expected
				// terminals can be set
				for (org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal nextFollow : newFollowSet) {
					lastTokenIndex = 0;
					setPosition(nextFollow, i);
				}
				newFollowSet.clear();
				// normal tokens do reduce the follow set - only elements that match the token are
				// kept
				for (org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal nextFollow : currentFollowSet) {
					if (nextFollow.getTerminal().getTokenNames().contains(getTokenNames()[nextToken.getType()])) {
						// keep this one - it matches
						java.util.Collection<org.sintef.thingml.resource.thingml.util.ThingmlPair<org.sintef.thingml.resource.thingml.IThingmlExpectedElement, org.sintef.thingml.resource.thingml.mopp.ThingmlContainedFeature[]>> newFollowers = nextFollow.getTerminal().getFollowers();
						for (org.sintef.thingml.resource.thingml.util.ThingmlPair<org.sintef.thingml.resource.thingml.IThingmlExpectedElement, org.sintef.thingml.resource.thingml.mopp.ThingmlContainedFeature[]> newFollowerPair : newFollowers) {
							org.sintef.thingml.resource.thingml.IThingmlExpectedElement newFollower = newFollowerPair.getLeft();
							org.eclipse.emf.ecore.EObject container = getLastIncompleteElement();
							org.sintef.thingml.resource.thingml.grammar.ThingmlContainmentTrace containmentTrace = new org.sintef.thingml.resource.thingml.grammar.ThingmlContainmentTrace(null, newFollowerPair.getRight());
							org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal newFollowTerminal = new org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal(container, newFollower, followSetID, containmentTrace);
							newFollowSet.add(newFollowTerminal);
							expectedElements.add(newFollowTerminal);
						}
					}
				}
				currentFollowSet.clear();
				currentFollowSet.addAll(newFollowSet);
			}
			followSetID++;
		}
		// after the last token in the stream we must set the position for the elements
		// that were added during the last iteration of the loop
		for (org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal nextFollow : newFollowSet) {
			lastTokenIndex = 0;
			setPosition(nextFollow, i);
		}
		return this.expectedElements;
	}
	
	public void setPosition(org.sintef.thingml.resource.thingml.mopp.ThingmlExpectedTerminal expectedElement, int tokenIndex) {
		int currentIndex = Math.max(0, tokenIndex);
		for (int index = lastTokenIndex; index < currentIndex; index++) {
			if (index >= input.size()) {
				break;
			}
			org.antlr.runtime3_4_0.CommonToken tokenAtIndex = (org.antlr.runtime3_4_0.CommonToken) input.get(index);
			stopIncludingHiddenTokens = tokenAtIndex.getStopIndex() + 1;
			if (tokenAtIndex.getChannel() != 99 && !anonymousTokens.contains(tokenAtIndex)) {
				stopExcludingHiddenTokens = tokenAtIndex.getStopIndex() + 1;
			}
		}
		lastTokenIndex = Math.max(0, currentIndex);
		expectedElement.setPosition(stopExcludingHiddenTokens, stopIncludingHiddenTokens);
	}
	
	public Object recoverFromMismatchedToken(org.antlr.runtime3_4_0.IntStream input, int ttype, org.antlr.runtime3_4_0.BitSet follow) throws org.antlr.runtime3_4_0.RecognitionException {
		if (!rememberExpectedElements) {
			return super.recoverFromMismatchedToken(input, ttype, follow);
		} else {
			return null;
		}
	}
	
	/**
	 * Translates errors thrown by the parser into human readable messages.
	 */
	public void reportError(final org.antlr.runtime3_4_0.RecognitionException e)  {
		String message = e.getMessage();
		if (e instanceof org.antlr.runtime3_4_0.MismatchedTokenException) {
			org.antlr.runtime3_4_0.MismatchedTokenException mte = (org.antlr.runtime3_4_0.MismatchedTokenException) e;
			String expectedTokenName = formatTokenName(mte.expecting);
			String actualTokenName = formatTokenName(e.token.getType());
			message = "Syntax error on token \"" + e.token.getText() + " (" + actualTokenName + ")\", \"" + expectedTokenName + "\" expected";
		} else if (e instanceof org.antlr.runtime3_4_0.MismatchedTreeNodeException) {
			org.antlr.runtime3_4_0.MismatchedTreeNodeException mtne = (org.antlr.runtime3_4_0.MismatchedTreeNodeException) e;
			String expectedTokenName = formatTokenName(mtne.expecting);
			message = "mismatched tree node: " + "xxx" + "; tokenName " + expectedTokenName;
		} else if (e instanceof org.antlr.runtime3_4_0.NoViableAltException) {
			message = "Syntax error on token \"" + e.token.getText() + "\", check following tokens";
		} else if (e instanceof org.antlr.runtime3_4_0.EarlyExitException) {
			message = "Syntax error on token \"" + e.token.getText() + "\", delete this token";
		} else if (e instanceof org.antlr.runtime3_4_0.MismatchedSetException) {
			org.antlr.runtime3_4_0.MismatchedSetException mse = (org.antlr.runtime3_4_0.MismatchedSetException) e;
			message = "mismatched token: " + e.token + "; expecting set " + mse.expecting;
		} else if (e instanceof org.antlr.runtime3_4_0.MismatchedNotSetException) {
			org.antlr.runtime3_4_0.MismatchedNotSetException mse = (org.antlr.runtime3_4_0.MismatchedNotSetException) e;
			message = "mismatched token: " +  e.token + "; expecting set " + mse.expecting;
		} else if (e instanceof org.antlr.runtime3_4_0.FailedPredicateException) {
			org.antlr.runtime3_4_0.FailedPredicateException fpe = (org.antlr.runtime3_4_0.FailedPredicateException) e;
			message = "rule " + fpe.ruleName + " failed predicate: {" +  fpe.predicateText + "}?";
		}
		// the resource may be null if the parser is used for code completion
		final String finalMessage = message;
		if (e.token instanceof org.antlr.runtime3_4_0.CommonToken) {
			final org.antlr.runtime3_4_0.CommonToken ct = (org.antlr.runtime3_4_0.CommonToken) e.token;
			addErrorToResource(finalMessage, ct.getCharPositionInLine(), ct.getLine(), ct.getStartIndex(), ct.getStopIndex());
		} else {
			addErrorToResource(finalMessage, e.token.getCharPositionInLine(), e.token.getLine(), 1, 5);
		}
	}
	
	/**
	 * Translates errors thrown by the lexer into human readable messages.
	 */
	public void reportLexicalError(final org.antlr.runtime3_4_0.RecognitionException e)  {
		String message = "";
		if (e instanceof org.antlr.runtime3_4_0.MismatchedTokenException) {
			org.antlr.runtime3_4_0.MismatchedTokenException mte = (org.antlr.runtime3_4_0.MismatchedTokenException) e;
			message = "Syntax error on token \"" + ((char) e.c) + "\", \"" + (char) mte.expecting + "\" expected";
		} else if (e instanceof org.antlr.runtime3_4_0.NoViableAltException) {
			message = "Syntax error on token \"" + ((char) e.c) + "\", delete this token";
		} else if (e instanceof org.antlr.runtime3_4_0.EarlyExitException) {
			org.antlr.runtime3_4_0.EarlyExitException eee = (org.antlr.runtime3_4_0.EarlyExitException) e;
			message = "required (...)+ loop (decision=" + eee.decisionNumber + ") did not match anything; on line " + e.line + ":" + e.charPositionInLine + " char=" + ((char) e.c) + "'";
		} else if (e instanceof org.antlr.runtime3_4_0.MismatchedSetException) {
			org.antlr.runtime3_4_0.MismatchedSetException mse = (org.antlr.runtime3_4_0.MismatchedSetException) e;
			message = "mismatched char: '" + ((char) e.c) + "' on line " + e.line + ":" + e.charPositionInLine + "; expecting set " + mse.expecting;
		} else if (e instanceof org.antlr.runtime3_4_0.MismatchedNotSetException) {
			org.antlr.runtime3_4_0.MismatchedNotSetException mse = (org.antlr.runtime3_4_0.MismatchedNotSetException) e;
			message = "mismatched char: '" + ((char) e.c) + "' on line " + e.line + ":" + e.charPositionInLine + "; expecting set " + mse.expecting;
		} else if (e instanceof org.antlr.runtime3_4_0.MismatchedRangeException) {
			org.antlr.runtime3_4_0.MismatchedRangeException mre = (org.antlr.runtime3_4_0.MismatchedRangeException) e;
			message = "mismatched char: '" + ((char) e.c) + "' on line " + e.line + ":" + e.charPositionInLine + "; expecting set '" + (char) mre.a + "'..'" + (char) mre.b + "'";
		} else if (e instanceof org.antlr.runtime3_4_0.FailedPredicateException) {
			org.antlr.runtime3_4_0.FailedPredicateException fpe = (org.antlr.runtime3_4_0.FailedPredicateException) e;
			message = "rule " + fpe.ruleName + " failed predicate: {" + fpe.predicateText + "}?";
		}
		addErrorToResource(message, e.charPositionInLine, e.line, lexerExceptionsPosition.get(lexerExceptions.indexOf(e)), lexerExceptionsPosition.get(lexerExceptions.indexOf(e)));
	}
	
	private void startIncompleteElement(Object object) {
		if (object instanceof org.eclipse.emf.ecore.EObject) {
			this.incompleteObjects.add((org.eclipse.emf.ecore.EObject) object);
		}
	}
	
	private void completedElement(Object object, boolean isContainment) {
		if (isContainment && !this.incompleteObjects.isEmpty()) {
			boolean exists = this.incompleteObjects.remove(object);
			if (!exists) {
			}
		}
		if (object instanceof org.eclipse.emf.ecore.EObject) {
			this.tokenIndexOfLastCompleteElement = getTokenStream().index();
			this.expectedElementsIndexOfLastCompleteElement = expectedElements.size() - 1;
		}
	}
	
	private org.eclipse.emf.ecore.EObject getLastIncompleteElement() {
		if (incompleteObjects.isEmpty()) {
			return null;
		}
		return incompleteObjects.get(incompleteObjects.size() - 1);
	}
	
}

start returns [ org.eclipse.emf.ecore.EObject element = null]
:
	{
		// follow set for start rule(s)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[0]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[4]);
		expectedElementsIndexOfLastCompleteElement = 0;
	}
	(
		c0 = parse_org_sintef_thingml_ThingMLModel{ element = c0; }
	)
	EOF	{
		retrieveLayoutInformation(element, null, null, false);
	}
	
;

parse_org_sintef_thingml_ThingMLModel returns [org.sintef.thingml.ThingMLModel element = null]
@init{
}
:
	(
		(
			a0 = 'import' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThingMLModel();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_0_0_0_0_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[5]);
			}
			
			(
				a1 = STRING_LITERAL				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThingMLModel();
						startIncompleteElement(element);
					}
					if (a1 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("STRING_LITERAL");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING_ML_MODEL__IMPORTS), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
						}
						String resolved = (String) resolvedObject;
						org.sintef.thingml.ThingMLModel proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThingMLModel();
						collectHiddenTokens(element);
						registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.ThingMLModel, org.sintef.thingml.ThingMLModel>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getThingMLModelImportsReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING_ML_MODEL__IMPORTS), resolved, proxy);
						if (proxy != null) {
							Object value = proxy;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING_ML_MODEL__IMPORTS, value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_0_0_0_0_0_0_3, proxy, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, proxy);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[6]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[7]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[8]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[9]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[10]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[11]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[12]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[13]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[14]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[15]);
	}
	
	(
		(
			(
				(
					a2_0 = parse_org_sintef_thingml_Type					{
						if (terminateParsing) {
							throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
						}
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThingMLModel();
							startIncompleteElement(element);
						}
						if (a2_0 != null) {
							if (a2_0 != null) {
								Object value = a2_0;
								addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING_ML_MODEL__TYPES, value);
								completedElement(value, true);
							}
							collectHiddenTokens(element);
							retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_0_0_0_1_0_0_1_0_0_0, a2_0, true);
							copyLocalizationInfos(a2_0, element);
						}
					}
				)
				{
					// expected elements (follow set)
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[16]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[17]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[18]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[19]);
				}
				
				
				|				(
					a3_0 = parse_org_sintef_thingml_Configuration					{
						if (terminateParsing) {
							throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
						}
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThingMLModel();
							startIncompleteElement(element);
						}
						if (a3_0 != null) {
							if (a3_0 != null) {
								Object value = a3_0;
								addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING_ML_MODEL__CONFIGS, value);
								completedElement(value, true);
							}
							collectHiddenTokens(element);
							retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_0_0_0_1_0_0_1_0_1_0, a3_0, true);
							copyLocalizationInfos(a3_0, element);
						}
					}
				)
				{
					// expected elements (follow set)
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[20]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[21]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[22]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[23]);
				}
				
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[24]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[25]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[26]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[27]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[28]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[29]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[30]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[31]);
	}
	
;

parse_org_sintef_thingml_Message returns [org.sintef.thingml.Message element = null]
@init{
}
:
	a0 = 'message' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[32]);
	}
	
	(
		a1 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.MESSAGE__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.MESSAGE__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_2, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[33]);
	}
	
	a2 = '(' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_3, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMessage(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[34]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[35]);
	}
	
	(
		(
			(
				a3_0 = parse_org_sintef_thingml_Parameter				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
						startIncompleteElement(element);
					}
					if (a3_0 != null) {
						if (a3_0 != null) {
							Object value = a3_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.MESSAGE__PARAMETERS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_4_0_0_0, a3_0, true);
						copyLocalizationInfos(a3_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[36]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[37]);
			}
			
			(
				(
					a4 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_4_0_0_1_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMessage(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[38]);
					}
					
					(
						a5_0 = parse_org_sintef_thingml_Parameter						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
								startIncompleteElement(element);
							}
							if (a5_0 != null) {
								if (a5_0 != null) {
									Object value = a5_0;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.MESSAGE__PARAMETERS, value);
									completedElement(value, true);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_4_0_0_1_0_0_2, a5_0, true);
								copyLocalizationInfos(a5_0, element);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[39]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[40]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[41]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[42]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[43]);
	}
	
	a6 = ')' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_5, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a6, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMessage(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[44]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[45]);
	}
	
	(
		(
			(
				a7_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
						startIncompleteElement(element);
					}
					if (a7_0 != null) {
						if (a7_0 != null) {
							Object value = a7_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.MESSAGE__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_6_0_0_0, a7_0, true);
						copyLocalizationInfos(a7_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMessage(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[46]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[47]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMessage(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[48]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[49]);
	}
	
	a8 = ';' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_1_0_0_7, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a8, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[50]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[51]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[52]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[53]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[54]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[55]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[56]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[57]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[58]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[59]);
	}
	
;

parse_org_sintef_thingml_Function returns [org.sintef.thingml.Function element = null]
@init{
}
:
	a0 = 'function' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[60]);
	}
	
	(
		a1 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_2, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[61]);
	}
	
	a2 = '(' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_3, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[62]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[63]);
	}
	
	(
		(
			(
				a3_0 = parse_org_sintef_thingml_Parameter				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
						startIncompleteElement(element);
					}
					if (a3_0 != null) {
						if (a3_0 != null) {
							Object value = a3_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.FUNCTION__PARAMETERS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_4_0_0_0, a3_0, true);
						copyLocalizationInfos(a3_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[64]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[65]);
			}
			
			(
				(
					a4 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_4_0_0_1_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[66]);
					}
					
					(
						a5_0 = parse_org_sintef_thingml_Parameter						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
								startIncompleteElement(element);
							}
							if (a5_0 != null) {
								if (a5_0 != null) {
									Object value = a5_0;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.FUNCTION__PARAMETERS, value);
									completedElement(value, true);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_4_0_0_1_0_0_2, a5_0, true);
								copyLocalizationInfos(a5_0, element);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[67]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[68]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[69]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[70]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[71]);
	}
	
	a6 = ')' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_5, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a6, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[72]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[73]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[74]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[75]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[76]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[77]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[78]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[79]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[80]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[81]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[82]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[83]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[84]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[85]);
	}
	
	(
		(
			(
				a7_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
						startIncompleteElement(element);
					}
					if (a7_0 != null) {
						if (a7_0 != null) {
							Object value = a7_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.FUNCTION__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_6_0_0_0, a7_0, true);
						copyLocalizationInfos(a7_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[86]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[87]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[88]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[89]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[90]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[91]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[92]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[93]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[94]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[95]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[96]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[97]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[98]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[99]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[100]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[101]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[102]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[103]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[104]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[105]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[106]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[107]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[108]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[109]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[110]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[111]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[112]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[113]);
	}
	
	(
		(
			a8 = ':' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_7_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a8, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[114]);
			}
			
			(
				a9 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
						startIncompleteElement(element);
					}
					if (a9 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a9.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION__TYPE), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a9).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a9).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a9).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a9).getStopIndex());
						}
						String resolved = (String) resolvedObject;
						org.sintef.thingml.Type proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						collectHiddenTokens(element);
						registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.TypedElement, org.sintef.thingml.Type>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getTypedElementTypeReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION__TYPE), resolved, proxy);
						if (proxy != null) {
							Object value = proxy;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION__TYPE), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_7_0_0_3, proxy, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a9, element);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a9, proxy);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[115]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[116]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[117]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[118]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[119]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[120]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[121]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[122]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[123]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[124]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[125]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[126]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[127]);
			}
			
			(
				(
					a10 = '[' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_7_0_0_4_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a10, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[128]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[129]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[130]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[131]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[132]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[133]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[134]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[135]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[136]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[137]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[138]);
					}
					
					(
						a11_0 = parse_org_sintef_thingml_Expression						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
								startIncompleteElement(element);
							}
							if (a11_0 != null) {
								if (a11_0 != null) {
									Object value = a11_0;
									element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION__CARDINALITY), value);
									completedElement(value, true);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_7_0_0_4_0_0_1, a11_0, true);
								copyLocalizationInfos(a11_0, element);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[139]);
					}
					
					a12 = ']' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_7_0_0_4_0_0_2, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a12, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[140]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[141]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[142]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[143]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[144]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[145]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[146]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[147]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[148]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[149]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[150]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[151]);
					}
					
				)
				
			)?			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[152]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[153]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[154]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[155]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[156]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[157]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[158]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[159]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[160]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[161]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[162]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[163]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[164]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[165]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[166]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[167]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[168]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[169]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[170]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[171]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[172]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[173]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[174]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[175]);
	}
	
	(
		a13_0 = parse_org_sintef_thingml_Action		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
				startIncompleteElement(element);
			}
			if (a13_0 != null) {
				if (a13_0 != null) {
					Object value = a13_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION__BODY), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_2_0_0_9, a13_0, true);
				copyLocalizationInfos(a13_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[176]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[177]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[178]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[179]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[180]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[181]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[182]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[183]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[184]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[185]);
	}
	
;

parse_org_sintef_thingml_Thing returns [org.sintef.thingml.Thing element = null]
@init{
}
:
	a0 = 'thing' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[186]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[187]);
	}
	
	(
		(
			(
				a1 = T_ASPECT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a1 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("T_ASPECT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING__FRAGMENT), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
						}
						java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING__FRAGMENT), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_1_0_0_1, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[188]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[189]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_3, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[190]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[191]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[192]);
	}
	
	(
		(
			a3 = 'includes' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_4_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[193]);
			}
			
			(
				a4 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a4 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a4.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING__INCLUDES), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a4).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStopIndex());
						}
						String resolved = (String) resolvedObject;
						org.sintef.thingml.Thing proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						collectHiddenTokens(element);
						registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Thing, org.sintef.thingml.Thing>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getThingIncludesReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING__INCLUDES), resolved, proxy);
						if (proxy != null) {
							Object value = proxy;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__INCLUDES, value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_4_0_0_3, proxy, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, element);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, proxy);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[194]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[195]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[196]);
			}
			
			(
				(
					a5 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_4_0_0_4_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[197]);
					}
					
					(
						a6 = TEXT						
						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
								startIncompleteElement(element);
							}
							if (a6 != null) {
								org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
								tokenResolver.setOptions(getOptions());
								org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
								tokenResolver.resolve(a6.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING__INCLUDES), result);
								Object resolvedObject = result.getResolvedToken();
								if (resolvedObject == null) {
									addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a6).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a6).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a6).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a6).getStopIndex());
								}
								String resolved = (String) resolvedObject;
								org.sintef.thingml.Thing proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
								collectHiddenTokens(element);
								registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Thing, org.sintef.thingml.Thing>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getThingIncludesReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.THING__INCLUDES), resolved, proxy);
								if (proxy != null) {
									Object value = proxy;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__INCLUDES, value);
									completedElement(value, false);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_4_0_0_4_0_0_2, proxy, true);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a6, element);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a6, proxy);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[198]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[199]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[200]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[201]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[202]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[203]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[204]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[205]);
	}
	
	(
		(
			(
				a7_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a7_0 != null) {
						if (a7_0 != null) {
							Object value = a7_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_5_0_0_0, a7_0, true);
						copyLocalizationInfos(a7_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[206]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[207]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[208]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[209]);
	}
	
	a8 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_7, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a8, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[210]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[211]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[212]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[213]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[214]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[215]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[216]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[217]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[218]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[219]);
	}
	
	(
		(
			(
				a9_0 = parse_org_sintef_thingml_Message				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a9_0 != null) {
						if (a9_0 != null) {
							Object value = a9_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__MESSAGES, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_8_0_0_0, a9_0, true);
						copyLocalizationInfos(a9_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[220]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[221]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[222]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[223]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[224]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[225]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[226]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[227]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[228]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[229]);
			}
			
			
			|			(
				a10_0 = parse_org_sintef_thingml_Function				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a10_0 != null) {
						if (a10_0 != null) {
							Object value = a10_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__FUNCTIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_8_0_1_0, a10_0, true);
						copyLocalizationInfos(a10_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[230]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[231]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[232]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[233]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[234]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[235]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[236]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[237]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[238]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[239]);
			}
			
			
			|			(
				a11_0 = parse_org_sintef_thingml_Property				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a11_0 != null) {
						if (a11_0 != null) {
							Object value = a11_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__PROPERTIES, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_8_0_2_0, a11_0, true);
						copyLocalizationInfos(a11_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[240]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[241]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[242]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[243]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[244]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[245]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[246]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[247]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[248]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[249]);
			}
			
			
			|			(
				a12_0 = parse_org_sintef_thingml_PropertyAssign				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a12_0 != null) {
						if (a12_0 != null) {
							Object value = a12_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__ASSIGN, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_8_0_3_0, a12_0, true);
						copyLocalizationInfos(a12_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[250]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[251]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[252]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[253]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[254]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[255]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[256]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[257]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[258]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[259]);
			}
			
			
			|			(
				a13_0 = parse_org_sintef_thingml_Port				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a13_0 != null) {
						if (a13_0 != null) {
							Object value = a13_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__PORTS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_8_0_4_0, a13_0, true);
						copyLocalizationInfos(a13_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[260]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[261]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[262]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[263]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[264]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[265]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[266]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[267]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[268]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[269]);
			}
			
			
			|			(
				a14_0 = parse_org_sintef_thingml_StateMachine				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
						startIncompleteElement(element);
					}
					if (a14_0 != null) {
						if (a14_0 != null) {
							Object value = a14_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.THING__BEHAVIOUR, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_8_0_5_0, a14_0, true);
						copyLocalizationInfos(a14_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[270]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[271]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[272]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[273]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[274]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[275]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[276]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[277]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[278]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[279]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[280]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[281]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[282]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[283]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[284]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[285]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[286]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[287]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[288]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[289]);
	}
	
	a15 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_3_0_0_10, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a15, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[290]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[291]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[292]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[293]);
	}
	
;

parse_org_sintef_thingml_RequiredPort returns [org.sintef.thingml.RequiredPort element = null]
@init{
}
:
	(
		(
			(
				a0 = T_OPTIONAL				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
						startIncompleteElement(element);
					}
					if (a0 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("T_OPTIONAL");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__OPTIONAL), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
						}
						java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__OPTIONAL), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_1_0_0_0, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[294]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[295]);
	}
	
	a1 = 'required' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[296]);
	}
	
	a2 = 'port' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_4, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[297]);
	}
	
	(
		a3 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
				startIncompleteElement(element);
			}
			if (a3 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a3.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a3).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_6, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getRequiredPort(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[298]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[299]);
	}
	
	(
		(
			(
				a4_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_7_0_0_0, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getRequiredPort(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[300]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[301]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getRequiredPort(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[302]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[303]);
	}
	
	a5 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_9, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[304]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[305]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[306]);
	}
	
	(
		(
			a6 = 'receives' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_10_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a6, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[307]);
			}
			
			(
				a7 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
						startIncompleteElement(element);
					}
					if (a7 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a7.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__RECEIVES), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a7).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a7).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a7).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a7).getStopIndex());
						}
						String resolved = (String) resolvedObject;
						org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
						collectHiddenTokens(element);
						registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Port, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPortReceivesReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__RECEIVES), resolved, proxy);
						if (proxy != null) {
							Object value = proxy;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__RECEIVES, value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_10_0_0_2, proxy, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a7, element);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a7, proxy);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[308]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[309]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[310]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[311]);
			}
			
			(
				(
					a8 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_10_0_0_3_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a8, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[312]);
					}
					
					(
						a9 = TEXT						
						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
								startIncompleteElement(element);
							}
							if (a9 != null) {
								org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
								tokenResolver.setOptions(getOptions());
								org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
								tokenResolver.resolve(a9.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__RECEIVES), result);
								Object resolvedObject = result.getResolvedToken();
								if (resolvedObject == null) {
									addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a9).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a9).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a9).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a9).getStopIndex());
								}
								String resolved = (String) resolvedObject;
								org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
								collectHiddenTokens(element);
								registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Port, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPortReceivesReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__RECEIVES), resolved, proxy);
								if (proxy != null) {
									Object value = proxy;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__RECEIVES, value);
									completedElement(value, false);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_10_0_0_3_0_0_2, proxy, true);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a9, element);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a9, proxy);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[313]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[314]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[315]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[316]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[317]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[318]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[319]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[320]);
			}
			
			
			|			a10 = 'sends' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_10_0_1_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a10, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[321]);
			}
			
			(
				a11 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
						startIncompleteElement(element);
					}
					if (a11 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a11.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__SENDS), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a11).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a11).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a11).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a11).getStopIndex());
						}
						String resolved = (String) resolvedObject;
						org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
						collectHiddenTokens(element);
						registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Port, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPortSendsReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__SENDS), resolved, proxy);
						if (proxy != null) {
							Object value = proxy;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__SENDS, value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_10_0_1_2, proxy, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a11, element);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a11, proxy);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[322]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[323]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[324]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[325]);
			}
			
			(
				(
					a12 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_10_0_1_3_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a12, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[326]);
					}
					
					(
						a13 = TEXT						
						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
								startIncompleteElement(element);
							}
							if (a13 != null) {
								org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
								tokenResolver.setOptions(getOptions());
								org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
								tokenResolver.resolve(a13.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__SENDS), result);
								Object resolvedObject = result.getResolvedToken();
								if (resolvedObject == null) {
									addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a13).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a13).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a13).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a13).getStopIndex());
								}
								String resolved = (String) resolvedObject;
								org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
								collectHiddenTokens(element);
								registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Port, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPortSendsReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__SENDS), resolved, proxy);
								if (proxy != null) {
									Object value = proxy;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.REQUIRED_PORT__SENDS, value);
									completedElement(value, false);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_10_0_1_3_0_0_2, proxy, true);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a13, element);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a13, proxy);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[327]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[328]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[329]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[330]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[331]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[332]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[333]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[334]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[335]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[336]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[337]);
	}
	
	a14 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_4_0_0_12, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a14, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[338]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[339]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[340]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[341]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[342]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[343]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[344]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[345]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[346]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[347]);
	}
	
;

parse_org_sintef_thingml_ProvidedPort returns [org.sintef.thingml.ProvidedPort element = null]
@init{
}
:
	a0 = 'provided' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_1, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[348]);
	}
	
	a1 = 'port' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_3, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[349]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_5, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProvidedPort(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[350]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[351]);
	}
	
	(
		(
			(
				a3_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
						startIncompleteElement(element);
					}
					if (a3_0 != null) {
						if (a3_0 != null) {
							Object value = a3_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_6_0_0_0, a3_0, true);
						copyLocalizationInfos(a3_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProvidedPort(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[352]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[353]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProvidedPort(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[354]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[355]);
	}
	
	a4 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_8, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[356]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[357]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[358]);
	}
	
	(
		(
			a5 = 'receives' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_9_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[359]);
			}
			
			(
				a6 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
						startIncompleteElement(element);
					}
					if (a6 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a6.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__RECEIVES), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a6).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a6).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a6).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a6).getStopIndex());
						}
						String resolved = (String) resolvedObject;
						org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
						collectHiddenTokens(element);
						registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Port, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPortReceivesReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__RECEIVES), resolved, proxy);
						if (proxy != null) {
							Object value = proxy;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__RECEIVES, value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_9_0_0_2, proxy, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a6, element);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a6, proxy);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[360]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[361]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[362]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[363]);
			}
			
			(
				(
					a7 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_9_0_0_3_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[364]);
					}
					
					(
						a8 = TEXT						
						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
								startIncompleteElement(element);
							}
							if (a8 != null) {
								org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
								tokenResolver.setOptions(getOptions());
								org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
								tokenResolver.resolve(a8.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__RECEIVES), result);
								Object resolvedObject = result.getResolvedToken();
								if (resolvedObject == null) {
									addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a8).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a8).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a8).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a8).getStopIndex());
								}
								String resolved = (String) resolvedObject;
								org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
								collectHiddenTokens(element);
								registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Port, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPortReceivesReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__RECEIVES), resolved, proxy);
								if (proxy != null) {
									Object value = proxy;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__RECEIVES, value);
									completedElement(value, false);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_9_0_0_3_0_0_2, proxy, true);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a8, element);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a8, proxy);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[365]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[366]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[367]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[368]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[369]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[370]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[371]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[372]);
			}
			
			
			|			a9 = 'sends' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_9_0_1_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a9, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[373]);
			}
			
			(
				a10 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
						startIncompleteElement(element);
					}
					if (a10 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a10.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__SENDS), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a10).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a10).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a10).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a10).getStopIndex());
						}
						String resolved = (String) resolvedObject;
						org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
						collectHiddenTokens(element);
						registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Port, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPortSendsReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__SENDS), resolved, proxy);
						if (proxy != null) {
							Object value = proxy;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__SENDS, value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_9_0_1_2, proxy, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a10, element);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a10, proxy);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[374]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[375]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[376]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[377]);
			}
			
			(
				(
					a11 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_9_0_1_3_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a11, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[378]);
					}
					
					(
						a12 = TEXT						
						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
								startIncompleteElement(element);
							}
							if (a12 != null) {
								org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
								tokenResolver.setOptions(getOptions());
								org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
								tokenResolver.resolve(a12.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__SENDS), result);
								Object resolvedObject = result.getResolvedToken();
								if (resolvedObject == null) {
									addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a12).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a12).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a12).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a12).getStopIndex());
								}
								String resolved = (String) resolvedObject;
								org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
								collectHiddenTokens(element);
								registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Port, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPortSendsReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__SENDS), resolved, proxy);
								if (proxy != null) {
									Object value = proxy;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.PROVIDED_PORT__SENDS, value);
									completedElement(value, false);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_9_0_1_3_0_0_2, proxy, true);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a12, element);
								copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a12, proxy);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[379]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[380]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[381]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[382]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[383]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[384]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[385]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[386]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[387]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[388]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[389]);
	}
	
	a13 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_5_0_0_11, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a13, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[390]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[391]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[392]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[393]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[394]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[395]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[396]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[397]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[398]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[399]);
	}
	
;

parse_org_sintef_thingml_Property returns [org.sintef.thingml.Property element = null]
@init{
}
:
	(
		(
			(
				a0 = T_READONLY				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
						startIncompleteElement(element);
					}
					if (a0 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("T_READONLY");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__CHANGEABLE), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
						}
						java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__CHANGEABLE), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_1_0_0_0, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[400]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[401]);
	}
	
	a1 = 'property' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[402]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_4, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[403]);
	}
	
	a3 = ':' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_6, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[404]);
	}
	
	(
		a4 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
				startIncompleteElement(element);
			}
			if (a4 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a4.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__TYPE), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a4).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Type proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.TypedElement, org.sintef.thingml.Type>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getTypedElementTypeReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__TYPE), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__TYPE), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_8, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[405]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[406]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[407]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[408]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[409]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[410]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[411]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[412]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[413]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[414]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[415]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[416]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[417]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[418]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[419]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[420]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[421]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[422]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[423]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[424]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[425]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[426]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[427]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[428]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[429]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[430]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[431]);
	}
	
	(
		(
			a5 = '[' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_9_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[432]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[433]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[434]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[435]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[436]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[437]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[438]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[439]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[440]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[441]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[442]);
			}
			
			(
				a6_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
						startIncompleteElement(element);
					}
					if (a6_0 != null) {
						if (a6_0 != null) {
							Object value = a6_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__CARDINALITY), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_9_0_0_1, a6_0, true);
						copyLocalizationInfos(a6_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[443]);
			}
			
			a7 = ']' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_9_0_0_2, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[444]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[445]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[446]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[447]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[448]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[449]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[450]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[451]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[452]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[453]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[454]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[455]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[456]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[457]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[458]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[459]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[460]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[461]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[462]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[463]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[464]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[465]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[466]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[467]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[468]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[469]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[470]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[471]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[472]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[473]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[474]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[475]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[476]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[477]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[478]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[479]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[480]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[481]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[482]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[483]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[484]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[485]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[486]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[487]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[488]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[489]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[490]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[491]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[492]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[493]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[494]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[495]);
	}
	
	(
		(
			a8 = '=' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_10_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a8, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[496]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[497]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[498]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[499]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[500]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[501]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[502]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[503]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[504]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[505]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[506]);
			}
			
			(
				a9_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
						startIncompleteElement(element);
					}
					if (a9_0 != null) {
						if (a9_0 != null) {
							Object value = a9_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY__INIT), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_10_0_0_3, a9_0, true);
						copyLocalizationInfos(a9_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[507]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[508]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[509]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[510]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[511]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[512]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[513]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[514]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[515]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[516]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[517]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[518]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[519]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[520]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[521]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[522]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[523]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[524]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[525]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[526]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[527]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[528]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[529]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[530]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[531]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[532]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[533]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[534]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[535]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[536]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[537]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[538]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[539]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[540]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[541]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[542]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[543]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[544]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[545]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[546]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[547]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[548]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[549]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[550]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[551]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[552]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[553]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[554]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[555]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[556]);
	}
	
	(
		(
			(
				a10_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
						startIncompleteElement(element);
					}
					if (a10_0 != null) {
						if (a10_0 != null) {
							Object value = a10_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.PROPERTY__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_6_0_0_11_0_0_0, a10_0, true);
						copyLocalizationInfos(a10_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[557]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[558]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[559]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[560]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[561]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[562]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[563]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[564]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[565]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[566]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[567]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[568]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[569]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[570]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[571]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[572]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[573]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[574]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[575]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[576]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[577]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[578]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[579]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[580]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[581]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getProperty(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[582]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[583]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[584]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[585]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[586]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[587]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[588]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[589]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[590]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[591]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[592]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[593]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[594]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[595]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[596]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[597]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[598]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[599]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[600]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[601]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[602]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[603]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[604]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[605]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[606]);
	}
	
;

parse_org_sintef_thingml_Parameter returns [org.sintef.thingml.Parameter element = null]
@init{
}
:
	(
		a0 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
				startIncompleteElement(element);
			}
			if (a0 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARAMETER__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARAMETER__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_7_0_0_0, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[607]);
	}
	
	a1 = ':' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_7_0_0_1, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[608]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARAMETER__TYPE), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Type proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.TypedElement, org.sintef.thingml.Type>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getTypedElementTypeReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARAMETER__TYPE), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARAMETER__TYPE), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_7_0_0_2, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[609]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[610]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[611]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[612]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[613]);
	}
	
	(
		(
			a3 = '[' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_7_0_0_3_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[614]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[615]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[616]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[617]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[618]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[619]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[620]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[621]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[622]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[623]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParameter(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[624]);
			}
			
			(
				a4_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARAMETER__CARDINALITY), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_7_0_0_3_0_0_1, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[625]);
			}
			
			a5 = ']' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_7_0_0_3_0_0_2, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[626]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[627]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[628]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[629]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[630]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[631]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[632]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[633]);
	}
	
;

parse_org_sintef_thingml_PrimitiveType returns [org.sintef.thingml.PrimitiveType element = null]
@init{
}
:
	a0 = 'datatype' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPrimitiveType();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_8_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[634]);
	}
	
	(
		a1 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPrimitiveType();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PRIMITIVE_TYPE__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PRIMITIVE_TYPE__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_8_0_0_2, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrimitiveType(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[635]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[636]);
	}
	
	(
		(
			(
				a2_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPrimitiveType();
						startIncompleteElement(element);
					}
					if (a2_0 != null) {
						if (a2_0 != null) {
							Object value = a2_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.PRIMITIVE_TYPE__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_8_0_0_3_0_0_0, a2_0, true);
						copyLocalizationInfos(a2_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrimitiveType(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[637]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[638]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrimitiveType(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[639]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[640]);
	}
	
	a3 = ';' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPrimitiveType();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_8_0_0_4, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[641]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[642]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[643]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[644]);
	}
	
;

parse_org_sintef_thingml_Enumeration returns [org.sintef.thingml.Enumeration element = null]
@init{
}
:
	a0 = 'enumeration' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumeration();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_9_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[645]);
	}
	
	(
		a1 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumeration();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUMERATION__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUMERATION__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_9_0_0_2, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[646]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[647]);
	}
	
	(
		(
			(
				a2_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumeration();
						startIncompleteElement(element);
					}
					if (a2_0 != null) {
						if (a2_0 != null) {
							Object value = a2_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.ENUMERATION__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_9_0_0_3_0_0_0, a2_0, true);
						copyLocalizationInfos(a2_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[648]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[649]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[650]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[651]);
	}
	
	a3 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumeration();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_9_0_0_5, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[652]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[653]);
	}
	
	(
		(
			(
				a4_0 = parse_org_sintef_thingml_EnumerationLiteral				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumeration();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.ENUMERATION__LITERALS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_9_0_0_6_0_0_0, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[654]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[655]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[656]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[657]);
	}
	
	a5 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumeration();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_9_0_0_7, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[658]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[659]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[660]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[661]);
	}
	
;

parse_org_sintef_thingml_EnumerationLiteral returns [org.sintef.thingml.EnumerationLiteral element = null]
@init{
}
:
	(
		a0 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumerationLiteral();
				startIncompleteElement(element);
			}
			if (a0 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUMERATION_LITERAL__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUMERATION_LITERAL__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_10_0_0_1, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumerationLiteral(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[662]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[663]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[664]);
	}
	
	(
		(
			(
				a1_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumerationLiteral();
						startIncompleteElement(element);
					}
					if (a1_0 != null) {
						if (a1_0 != null) {
							Object value = a1_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.ENUMERATION_LITERAL__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_10_0_0_2_0_0_0, a1_0, true);
						copyLocalizationInfos(a1_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumerationLiteral(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[665]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[666]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[667]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumerationLiteral(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[668]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEnumeration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[669]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[670]);
	}
	
;

parse_org_sintef_thingml_PlatformAnnotation returns [org.sintef.thingml.PlatformAnnotation element = null]
@init{
}
:
	(
		a0 = ANNOTATION		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPlatformAnnotation();
				startIncompleteElement(element);
			}
			if (a0 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("ANNOTATION");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PLATFORM_ANNOTATION__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PLATFORM_ANNOTATION__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_11_0_0_1, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[671]);
	}
	
	(
		a1 = STRING_LITERAL		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPlatformAnnotation();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("STRING_LITERAL");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PLATFORM_ANNOTATION__VALUE), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PLATFORM_ANNOTATION__VALUE), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_11_0_0_3, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMessage(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[672]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[673]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[674]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[675]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[676]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[677]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[678]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[679]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[680]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[681]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[682]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[683]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[684]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[685]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[686]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[687]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[688]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[689]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[690]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[691]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[692]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[693]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[694]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[695]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[696]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[697]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[698]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[699]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[700]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[701]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[702]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[703]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[704]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[705]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[706]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[707]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[708]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[709]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[710]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[711]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[712]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[713]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[714]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[715]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[716]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[717]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[718]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[719]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[720]);
	}
	
;

parse_org_sintef_thingml_StateMachine returns [org.sintef.thingml.StateMachine element = null]
@init{
}
:
	a0 = 'statechart' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_1, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[721]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[722]);
	}
	
	(
		(
			(
				a1 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
						startIncompleteElement(element);
					}
					if (a1 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__NAME), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
						}
						java.lang.String resolved = (java.lang.String) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__NAME), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_2_0_0_1, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[723]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[724]);
	}
	
	a2 = 'init' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_4, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[725]);
	}
	
	(
		a3 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
				startIncompleteElement(element);
			}
			if (a3 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a3.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__INITIAL), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a3).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.State proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Region, org.sintef.thingml.State>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getRegionInitialReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__INITIAL), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__INITIAL), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_6, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[726]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[727]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[728]);
	}
	
	(
		(
			a4 = 'keeps' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_7_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[729]);
			}
			
			(
				a5 = T_HISTORY				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
						startIncompleteElement(element);
					}
					if (a5 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("T_HISTORY");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a5.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__HISTORY), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a5).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a5).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a5).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a5).getStopIndex());
						}
						java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__HISTORY), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_7_0_0_2, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a5, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[730]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[731]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[732]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[733]);
	}
	
	(
		(
			(
				a6_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
						startIncompleteElement(element);
					}
					if (a6_0 != null) {
						if (a6_0 != null) {
							Object value = a6_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE_MACHINE__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_8_0_0_0, a6_0, true);
						copyLocalizationInfos(a6_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[734]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[735]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[736]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[737]);
	}
	
	a7 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_10, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[738]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[739]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[740]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[741]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[742]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[743]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[744]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[745]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[746]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[747]);
	}
	
	(
		(
			(
				a8_0 = parse_org_sintef_thingml_Property				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
						startIncompleteElement(element);
					}
					if (a8_0 != null) {
						if (a8_0 != null) {
							Object value = a8_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE_MACHINE__PROPERTIES, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_11_0_0_1, a8_0, true);
						copyLocalizationInfos(a8_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[748]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[749]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[750]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[751]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[752]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[753]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[754]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[755]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[756]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[757]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[758]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[759]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[760]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[761]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[762]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[763]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[764]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[765]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[766]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[767]);
	}
	
	(
		(
			a9 = 'on' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_12_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a9, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[768]);
			}
			
			a10 = 'entry' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_12_0_0_3, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a10, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[769]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[770]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[771]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[772]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[773]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[774]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[775]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[776]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[777]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[778]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[779]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[780]);
			}
			
			(
				a11_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
						startIncompleteElement(element);
					}
					if (a11_0 != null) {
						if (a11_0 != null) {
							Object value = a11_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__ENTRY), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_12_0_0_5, a11_0, true);
						copyLocalizationInfos(a11_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[781]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[782]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[783]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[784]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[785]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[786]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[787]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[788]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[789]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[790]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[791]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[792]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[793]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[794]);
	}
	
	(
		(
			a12 = 'on' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_13_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a12, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[795]);
			}
			
			a13 = 'exit' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_13_0_0_3, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a13, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[796]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[797]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[798]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[799]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[800]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[801]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[802]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[803]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[804]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[805]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[806]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[807]);
			}
			
			(
				a14_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
						startIncompleteElement(element);
					}
					if (a14_0 != null) {
						if (a14_0 != null) {
							Object value = a14_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE_MACHINE__EXIT), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_13_0_0_5, a14_0, true);
						copyLocalizationInfos(a14_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[808]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[809]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[810]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[811]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[812]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[813]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[814]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[815]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[816]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[817]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[818]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[819]);
	}
	
	(
		(
			(
				(
					a15_0 = parse_org_sintef_thingml_State					{
						if (terminateParsing) {
							throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
						}
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
							startIncompleteElement(element);
						}
						if (a15_0 != null) {
							if (a15_0 != null) {
								Object value = a15_0;
								addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE_MACHINE__SUBSTATE, value);
								completedElement(value, true);
							}
							collectHiddenTokens(element);
							retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_14_0_0_0_0_0_1, a15_0, true);
							copyLocalizationInfos(a15_0, element);
						}
					}
				)
				{
					// expected elements (follow set)
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[820]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[821]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[822]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[823]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[824]);
					addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[825]);
				}
				
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[826]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[827]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[828]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[829]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[830]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[831]);
			}
			
			
			|			(
				a16_0 = parse_org_sintef_thingml_InternalTransition				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
						startIncompleteElement(element);
					}
					if (a16_0 != null) {
						if (a16_0 != null) {
							Object value = a16_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE_MACHINE__INTERNAL, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_14_0_1_0, a16_0, true);
						copyLocalizationInfos(a16_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[832]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[833]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[834]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[835]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[836]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[837]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[838]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[839]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[840]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[841]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[842]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[843]);
	}
	
	(
		(
			(
				a17_0 = parse_org_sintef_thingml_ParallelRegion				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
						startIncompleteElement(element);
					}
					if (a17_0 != null) {
						if (a17_0 != null) {
							Object value = a17_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE_MACHINE__REGION, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_15_0_0_1, a17_0, true);
						copyLocalizationInfos(a17_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[844]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[845]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[846]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[847]);
	}
	
	a18 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStateMachine();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_12_0_0_17, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a18, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[848]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[849]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[850]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[851]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[852]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[853]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[854]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[855]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[856]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[857]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[858]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[859]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[860]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[861]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[862]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[863]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[864]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[865]);
	}
	
;

parse_org_sintef_thingml_State returns [org.sintef.thingml.State element = null]
@init{
}
:
	a0 = 'state' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[866]);
	}
	
	(
		a1 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_2, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[867]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[868]);
	}
	
	(
		(
			(
				a2_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
						startIncompleteElement(element);
					}
					if (a2_0 != null) {
						if (a2_0 != null) {
							Object value = a2_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_3_0_0_0, a2_0, true);
						copyLocalizationInfos(a2_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[869]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[870]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[871]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[872]);
	}
	
	a3 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_5, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[873]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[874]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[875]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[876]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[877]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[878]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[879]);
	}
	
	(
		(
			(
				a4_0 = parse_org_sintef_thingml_Property				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE__PROPERTIES, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_6_0_0_1, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[880]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[881]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[882]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[883]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[884]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[885]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[886]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[887]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[888]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[889]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[890]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[891]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[892]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[893]);
	}
	
	(
		(
			a5 = 'on' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_7_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[894]);
			}
			
			a6 = 'entry' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_7_0_0_3, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a6, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[895]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[896]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[897]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[898]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[899]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[900]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[901]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[902]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[903]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[904]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[905]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[906]);
			}
			
			(
				a7_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
						startIncompleteElement(element);
					}
					if (a7_0 != null) {
						if (a7_0 != null) {
							Object value = a7_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE__ENTRY), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_7_0_0_4, a7_0, true);
						copyLocalizationInfos(a7_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[907]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[908]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[909]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[910]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[911]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[912]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[913]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[914]);
	}
	
	(
		(
			a8 = 'on' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_8_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a8, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[915]);
			}
			
			a9 = 'exit' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_8_0_0_2, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a9, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[916]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[917]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[918]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[919]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[920]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[921]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[922]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[923]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[924]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[925]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[926]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[927]);
			}
			
			(
				a10_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
						startIncompleteElement(element);
					}
					if (a10_0 != null) {
						if (a10_0 != null) {
							Object value = a10_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STATE__EXIT), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_8_0_0_3, a10_0, true);
						copyLocalizationInfos(a10_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[928]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[929]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[930]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[931]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[932]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[933]);
	}
	
	(
		(
			(
				a11_0 = parse_org_sintef_thingml_Transition				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
						startIncompleteElement(element);
					}
					if (a11_0 != null) {
						if (a11_0 != null) {
							Object value = a11_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE__OUTGOING, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_9_0_0_0, a11_0, true);
						copyLocalizationInfos(a11_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[934]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[935]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[936]);
			}
			
			
			|			(
				a12_0 = parse_org_sintef_thingml_InternalTransition				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
						startIncompleteElement(element);
					}
					if (a12_0 != null) {
						if (a12_0 != null) {
							Object value = a12_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.STATE__INTERNAL, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_9_0_1_0, a12_0, true);
						copyLocalizationInfos(a12_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[937]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[938]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[939]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[940]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[941]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[942]);
	}
	
	a13 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_13_0_0_11, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a13, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[943]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[944]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[945]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[946]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[947]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[948]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[949]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[950]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[951]);
	}
	
	|//derived choice rules for sub-classes: 
	
	c0 = parse_org_sintef_thingml_StateMachine{ element = c0; /* this is a subclass or primitive expression choice */ }
	|	c1 = parse_org_sintef_thingml_CompositeState{ element = c1; /* this is a subclass or primitive expression choice */ }
	
;

parse_org_sintef_thingml_CompositeState returns [org.sintef.thingml.CompositeState element = null]
@init{
}
:
	a0 = 'composite' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[952]);
	}
	
	a1 = 'state' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[953]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_4, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[954]);
	}
	
	a3 = 'init' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_6, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[955]);
	}
	
	(
		a4 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
				startIncompleteElement(element);
			}
			if (a4 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a4.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__INITIAL), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a4).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.State proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Region, org.sintef.thingml.State>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getRegionInitialReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__INITIAL), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__INITIAL), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_8, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[956]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[957]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[958]);
	}
	
	(
		(
			a5 = 'keeps' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_9_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[959]);
			}
			
			(
				a6 = T_HISTORY				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
						startIncompleteElement(element);
					}
					if (a6 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("T_HISTORY");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a6.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__HISTORY), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a6).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a6).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a6).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a6).getStopIndex());
						}
						java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__HISTORY), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_9_0_0_2, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a6, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[960]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[961]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[962]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[963]);
	}
	
	(
		(
			(
				a7_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
						startIncompleteElement(element);
					}
					if (a7_0 != null) {
						if (a7_0 != null) {
							Object value = a7_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_10_0_0_0, a7_0, true);
						copyLocalizationInfos(a7_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[964]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[965]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[966]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[967]);
	}
	
	a8 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_12, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a8, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[968]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[969]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[970]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[971]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[972]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[973]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[974]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[975]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[976]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[977]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[978]);
	}
	
	(
		(
			(
				a9_0 = parse_org_sintef_thingml_Property				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
						startIncompleteElement(element);
					}
					if (a9_0 != null) {
						if (a9_0 != null) {
							Object value = a9_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__PROPERTIES, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_13_0_0_1, a9_0, true);
						copyLocalizationInfos(a9_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[979]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[980]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[981]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[982]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[983]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[984]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[985]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[986]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[987]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[988]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[989]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[990]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[991]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[992]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[993]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[994]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[995]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[996]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[997]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[998]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[999]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1000]);
	}
	
	(
		(
			a10 = 'on' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_14_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a10, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1001]);
			}
			
			a11 = 'entry' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_14_0_0_3, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a11, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1002]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1003]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1004]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1005]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1006]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1007]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1008]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1009]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1010]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1011]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1012]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1013]);
			}
			
			(
				a12_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
						startIncompleteElement(element);
					}
					if (a12_0 != null) {
						if (a12_0 != null) {
							Object value = a12_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__ENTRY), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_14_0_0_5, a12_0, true);
						copyLocalizationInfos(a12_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1014]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1015]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1016]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1017]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1018]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1019]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1020]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1021]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1022]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1023]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1024]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1025]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1026]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1027]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1028]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1029]);
	}
	
	(
		(
			a13 = 'on' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_15_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a13, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1030]);
			}
			
			a14 = 'exit' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_15_0_0_3, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a14, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1031]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1032]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1033]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1034]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1035]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1036]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1037]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1038]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1039]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1040]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1041]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1042]);
			}
			
			(
				a15_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
						startIncompleteElement(element);
					}
					if (a15_0 != null) {
						if (a15_0 != null) {
							Object value = a15_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__EXIT), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_15_0_0_5, a15_0, true);
						copyLocalizationInfos(a15_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1043]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1044]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1045]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1046]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1047]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1048]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1049]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1050]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1051]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1052]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1053]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1054]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1055]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1056]);
	}
	
	(
		(
			(
				a16_0 = parse_org_sintef_thingml_Transition				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
						startIncompleteElement(element);
					}
					if (a16_0 != null) {
						if (a16_0 != null) {
							Object value = a16_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__OUTGOING, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_16_0_0_0, a16_0, true);
						copyLocalizationInfos(a16_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1057]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1058]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1059]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1060]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1061]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1062]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1063]);
			}
			
			
			|			(
				a17_0 = parse_org_sintef_thingml_InternalTransition				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
						startIncompleteElement(element);
					}
					if (a17_0 != null) {
						if (a17_0 != null) {
							Object value = a17_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__INTERNAL, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_16_0_1_0, a17_0, true);
						copyLocalizationInfos(a17_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1064]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1065]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1066]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1067]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1068]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1069]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1070]);
			}
			
			
			|			(
				(
					a18_0 = parse_org_sintef_thingml_State					{
						if (terminateParsing) {
							throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
						}
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
							startIncompleteElement(element);
						}
						if (a18_0 != null) {
							if (a18_0 != null) {
								Object value = a18_0;
								addObjectToList(element, org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__SUBSTATE, value);
								completedElement(value, true);
							}
							collectHiddenTokens(element);
							retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_16_0_2_0_0_0_1, a18_0, true);
							copyLocalizationInfos(a18_0, element);
						}
					}
				)
				{
					// expected elements (follow set)
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1071]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1072]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1073]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1074]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1075]);
					addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1076]);
					addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1077]);
				}
				
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1078]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1079]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1080]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1081]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1082]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1083]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1084]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1085]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1086]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1087]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1088]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1089]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1090]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1091]);
	}
	
	(
		(
			(
				a19_0 = parse_org_sintef_thingml_ParallelRegion				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
						startIncompleteElement(element);
					}
					if (a19_0 != null) {
						if (a19_0 != null) {
							Object value = a19_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.COMPOSITE_STATE__REGION, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_17_0_0_1, a19_0, true);
						copyLocalizationInfos(a19_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1092]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1093]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1094]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1095]);
	}
	
	a20 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createCompositeState();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_14_0_0_19, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a20, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1096]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1097]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1098]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1099]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1100]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1101]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1102]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1103]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1104]);
	}
	
	|//derived choice rules for sub-classes: 
	
	c0 = parse_org_sintef_thingml_StateMachine{ element = c0; /* this is a subclass or primitive expression choice */ }
	
;

parse_org_sintef_thingml_ParallelRegion returns [org.sintef.thingml.ParallelRegion element = null]
@init{
}
:
	a0 = 'region' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1105]);
	}
	
	(
		a1 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_2, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1106]);
	}
	
	a2 = 'init' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_4, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1107]);
	}
	
	(
		a3 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
				startIncompleteElement(element);
			}
			if (a3 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a3.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__INITIAL), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a3).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.State proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Region, org.sintef.thingml.State>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getRegionInitialReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__INITIAL), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__INITIAL), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_6, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1108]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1109]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1110]);
	}
	
	(
		(
			a4 = 'keeps' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_7_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1111]);
			}
			
			(
				a5 = T_HISTORY				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
						startIncompleteElement(element);
					}
					if (a5 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("T_HISTORY");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a5.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__HISTORY), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a5).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a5).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a5).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a5).getStopIndex());
						}
						java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__HISTORY), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_7_0_0_2, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a5, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1112]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1113]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1114]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1115]);
	}
	
	(
		(
			(
				a6_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
						startIncompleteElement(element);
					}
					if (a6_0 != null) {
						if (a6_0 != null) {
							Object value = a6_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_8_0_0_0, a6_0, true);
						copyLocalizationInfos(a6_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1116]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1117]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1118]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1119]);
	}
	
	a7 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_10, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1120]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1121]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1122]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1123]);
	}
	
	(
		(
			(
				a8_0 = parse_org_sintef_thingml_State				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
						startIncompleteElement(element);
					}
					if (a8_0 != null) {
						if (a8_0 != null) {
							Object value = a8_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.PARALLEL_REGION__SUBSTATE, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_11_0_0_1, a8_0, true);
						copyLocalizationInfos(a8_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1124]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1125]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1126]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1127]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1128]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1129]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getParallelRegion(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1130]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1131]);
	}
	
	a9 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParallelRegion();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_15_0_0_13, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a9, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1132]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1133]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1134]);
	}
	
;

parse_org_sintef_thingml_Transition returns [org.sintef.thingml.Transition element = null]
@init{
}
:
	a0 = 'transition' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_1, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1135]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1136]);
	}
	
	(
		(
			(
				a1 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
						startIncompleteElement(element);
					}
					if (a1 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__NAME), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
						}
						java.lang.String resolved = (java.lang.String) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__NAME), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_2_0_0_1, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1137]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1138]);
	}
	
	a2 = '->' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_4, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1139]);
	}
	
	(
		a3 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
				startIncompleteElement(element);
			}
			if (a3 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a3.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__TARGET), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a3).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.State proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createState();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Transition, org.sintef.thingml.State>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getTransitionTargetReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__TARGET), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__TARGET), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_6, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1140]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1141]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1142]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1143]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1144]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1145]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1146]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1147]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1148]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1149]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1150]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1151]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1152]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1153]);
	}
	
	(
		(
			(
				a4_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.TRANSITION__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_7_0_0_0, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1154]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1155]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1156]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1157]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1158]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1159]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1160]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1161]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1162]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1163]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1164]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1165]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1166]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1167]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1168]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1169]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1170]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1171]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1172]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1173]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1174]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1175]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1176]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1177]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1178]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1179]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1180]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1181]);
	}
	
	(
		(
			a5 = 'event' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_8_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1182]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1183]);
			}
			
			(
				a6_0 = parse_org_sintef_thingml_Event				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
						startIncompleteElement(element);
					}
					if (a6_0 != null) {
						if (a6_0 != null) {
							Object value = a6_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.TRANSITION__EVENT, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_8_0_0_3, a6_0, true);
						copyLocalizationInfos(a6_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1184]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1185]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1186]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1187]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1188]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1189]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1190]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1191]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1192]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1193]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1194]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1195]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1196]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1197]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1198]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1199]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1200]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1201]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1202]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1203]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1204]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1205]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1206]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1207]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1208]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1209]);
	}
	
	(
		(
			a7 = 'guard' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_9_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1210]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1211]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1212]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1213]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1214]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1215]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1216]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1217]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1218]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1219]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1220]);
			}
			
			(
				a8_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
						startIncompleteElement(element);
					}
					if (a8_0 != null) {
						if (a8_0 != null) {
							Object value = a8_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__GUARD), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_9_0_0_3, a8_0, true);
						copyLocalizationInfos(a8_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1221]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1222]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1223]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1224]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1225]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1226]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1227]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1228]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1229]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1230]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1231]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1232]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1233]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1234]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1235]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1236]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1237]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1238]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1239]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1240]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1241]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1242]);
	}
	
	(
		(
			a9 = 'action' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_10_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a9, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1243]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1244]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1245]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1246]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1247]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1248]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1249]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1250]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1251]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1252]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1253]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1254]);
			}
			
			(
				a10_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
						startIncompleteElement(element);
					}
					if (a10_0 != null) {
						if (a10_0 != null) {
							Object value = a10_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__ACTION), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_10_0_0_3, a10_0, true);
						copyLocalizationInfos(a10_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1255]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1256]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1257]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1258]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1259]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1260]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1261]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1262]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1263]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1264]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1265]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1266]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1267]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1268]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1269]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1270]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1271]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1272]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1273]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1274]);
	}
	
	(
		(
			a11 = 'before' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_11_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a11, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1275]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1276]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1277]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1278]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1279]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1280]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1281]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1282]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1283]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1284]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1285]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1286]);
			}
			
			(
				a12_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
						startIncompleteElement(element);
					}
					if (a12_0 != null) {
						if (a12_0 != null) {
							Object value = a12_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__BEFORE), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_11_0_0_3, a12_0, true);
						copyLocalizationInfos(a12_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1287]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1288]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1289]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1290]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1291]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1292]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1293]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1294]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1295]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1296]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1297]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1298]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1299]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1300]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1301]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1302]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1303]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1304]);
	}
	
	(
		(
			a13 = 'after' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_12_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a13, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1305]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1306]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1307]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1308]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1309]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1310]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1311]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1312]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1313]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1314]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1315]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1316]);
			}
			
			(
				a14_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTransition();
						startIncompleteElement(element);
					}
					if (a14_0 != null) {
						if (a14_0 != null) {
							Object value = a14_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TRANSITION__AFTER), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_16_0_0_12_0_0_3, a14_0, true);
						copyLocalizationInfos(a14_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1317]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1318]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1319]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1320]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1321]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1322]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1323]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1324]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1325]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1326]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1327]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1328]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1329]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1330]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1331]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1332]);
	}
	
;

parse_org_sintef_thingml_InternalTransition returns [org.sintef.thingml.InternalTransition element = null]
@init{
}
:
	a0 = 'internal' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_1, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1333]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1334]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1335]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1336]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1337]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1338]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1339]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1340]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1341]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1342]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1343]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1344]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1345]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1346]);
	}
	
	(
		(
			(
				a1 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
						startIncompleteElement(element);
					}
					if (a1 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INTERNAL_TRANSITION__NAME), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
						}
						java.lang.String resolved = (java.lang.String) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INTERNAL_TRANSITION__NAME), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_2_0_0_1, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1347]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1348]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1349]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1350]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1351]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1352]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1353]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1354]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1355]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1356]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1357]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1358]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1359]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1360]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1361]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1362]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1363]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1364]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1365]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1366]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1367]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1368]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1369]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1370]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1371]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1372]);
	}
	
	(
		(
			(
				a2_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
						startIncompleteElement(element);
					}
					if (a2_0 != null) {
						if (a2_0 != null) {
							Object value = a2_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.INTERNAL_TRANSITION__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_3_0_0_0, a2_0, true);
						copyLocalizationInfos(a2_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1373]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1374]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1375]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1376]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1377]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1378]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1379]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1380]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1381]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1382]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1383]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1384]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1385]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1386]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1387]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1388]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1389]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1390]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1391]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1392]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1393]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1394]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1395]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1396]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1397]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1398]);
	}
	
	(
		(
			a3 = 'event' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_4_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1399]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1400]);
			}
			
			(
				a4_0 = parse_org_sintef_thingml_Event				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.INTERNAL_TRANSITION__EVENT, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_4_0_0_3, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1401]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1402]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1403]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1404]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1405]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1406]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1407]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1408]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1409]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1410]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1411]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1412]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1413]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1414]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1415]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1416]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1417]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1418]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1419]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1420]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1421]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1422]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1423]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1424]);
	}
	
	(
		(
			a5 = 'guard' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_5_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1425]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1426]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1427]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1428]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1429]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1430]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1431]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1432]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1433]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1434]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1435]);
			}
			
			(
				a6_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
						startIncompleteElement(element);
					}
					if (a6_0 != null) {
						if (a6_0 != null) {
							Object value = a6_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INTERNAL_TRANSITION__GUARD), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_5_0_0_3, a6_0, true);
						copyLocalizationInfos(a6_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1436]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1437]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1438]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1439]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1440]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1441]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1442]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1443]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1444]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1445]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1446]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1447]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1448]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1449]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1450]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1451]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1452]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1453]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1454]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1455]);
	}
	
	(
		(
			a7 = 'action' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_6_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1456]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1457]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1458]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1459]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1460]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1461]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1462]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1463]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1464]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1465]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1466]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInternalTransition(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1467]);
			}
			
			(
				a8_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInternalTransition();
						startIncompleteElement(element);
					}
					if (a8_0 != null) {
						if (a8_0 != null) {
							Object value = a8_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INTERNAL_TRANSITION__ACTION), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_17_0_0_6_0_0_3, a8_0, true);
						copyLocalizationInfos(a8_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1468]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1469]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1470]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1471]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1472]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1473]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1474]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1475]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1476]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1477]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1478]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1479]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1480]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1481]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1482]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1483]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1484]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1485]);
	}
	
;

parse_org_sintef_thingml_ReceiveMessage returns [org.sintef.thingml.ReceiveMessage element = null]
@init{
}
:
	(
		(
			(
				a0 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createReceiveMessage();
						startIncompleteElement(element);
					}
					if (a0 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RECEIVE_MESSAGE__NAME), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
						}
						java.lang.String resolved = (java.lang.String) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RECEIVE_MESSAGE__NAME), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_18_0_0_0_0_0_0, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1486]);
			}
			
			a1 = ':' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createReceiveMessage();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_18_0_0_0_0_0_2, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1487]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1488]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createReceiveMessage();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RECEIVE_MESSAGE__PORT), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Port proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.ReceiveMessage, org.sintef.thingml.Port>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getReceiveMessagePortReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RECEIVE_MESSAGE__PORT), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RECEIVE_MESSAGE__PORT), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_18_0_0_1, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1489]);
	}
	
	a3 = '?' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createReceiveMessage();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_18_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1490]);
	}
	
	(
		a4 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createReceiveMessage();
				startIncompleteElement(element);
			}
			if (a4 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a4.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RECEIVE_MESSAGE__MESSAGE), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a4).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.ReceiveMessage, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getReceiveMessageMessageReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RECEIVE_MESSAGE__MESSAGE), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RECEIVE_MESSAGE__MESSAGE), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_18_0_0_3, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1491]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1492]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1493]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1494]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1495]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1496]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1497]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1498]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1499]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1500]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1501]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1502]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1503]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1504]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1505]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1506]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1507]);
	}
	
;

parse_org_sintef_thingml_PropertyAssign returns [org.sintef.thingml.PropertyAssign element = null]
@init{
}
:
	a0 = 'set' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPropertyAssign();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_19_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1508]);
	}
	
	(
		a1 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPropertyAssign();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY_ASSIGN__PROPERTY), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Property proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.PropertyAssign, org.sintef.thingml.Property>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPropertyAssignPropertyReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY_ASSIGN__PROPERTY), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY_ASSIGN__PROPERTY), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_19_0_0_2, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1509]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1510]);
	}
	
	(
		(
			a2 = '[' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPropertyAssign();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_19_0_0_3_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1511]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1512]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1513]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1514]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1515]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1516]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1517]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1518]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1519]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1520]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1521]);
			}
			
			(
				a3_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPropertyAssign();
						startIncompleteElement(element);
					}
					if (a3_0 != null) {
						if (a3_0 != null) {
							Object value = a3_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.PROPERTY_ASSIGN__INDEX, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_19_0_0_3_0_0_1, a3_0, true);
						copyLocalizationInfos(a3_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1522]);
			}
			
			a4 = ']' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPropertyAssign();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_19_0_0_3_0_0_2, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1523]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1524]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1525]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1526]);
	}
	
	a5 = '=' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPropertyAssign();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_19_0_0_5, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1527]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1528]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1529]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1530]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1531]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1532]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1533]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1534]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1535]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1536]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1537]);
	}
	
	(
		a6_0 = parse_org_sintef_thingml_Expression		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPropertyAssign();
				startIncompleteElement(element);
			}
			if (a6_0 != null) {
				if (a6_0 != null) {
					Object value = a6_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY_ASSIGN__INIT), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_19_0_0_7, a6_0, true);
				copyLocalizationInfos(a6_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1538]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1539]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1540]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1541]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1542]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1543]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1544]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1545]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1546]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1547]);
	}
	
;

parse_org_sintef_thingml_Configuration returns [org.sintef.thingml.Configuration element = null]
@init{
}
:
	a0 = 'configuration' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1548]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1549]);
	}
	
	(
		(
			(
				a1 = T_ASPECT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
						startIncompleteElement(element);
					}
					if (a1 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("T_ASPECT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIGURATION__FRAGMENT), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
						}
						java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIGURATION__FRAGMENT), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_1_0_0_1, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1550]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1551]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIGURATION__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIGURATION__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_3, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1552]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1553]);
	}
	
	(
		(
			(
				a3_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
						startIncompleteElement(element);
					}
					if (a3_0 != null) {
						if (a3_0 != null) {
							Object value = a3_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.CONFIGURATION__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_4_0_0_0, a3_0, true);
						copyLocalizationInfos(a3_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1554]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1555]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1556]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1557]);
	}
	
	a4 = '{' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_6, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1558]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1559]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1560]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1561]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1562]);
	}
	
	(
		(
			(
				a5_0 = parse_org_sintef_thingml_Instance				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
						startIncompleteElement(element);
					}
					if (a5_0 != null) {
						if (a5_0 != null) {
							Object value = a5_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.CONFIGURATION__INSTANCES, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_7_0_0_0, a5_0, true);
						copyLocalizationInfos(a5_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1563]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1564]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1565]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1566]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1567]);
			}
			
			
			|			(
				a6_0 = parse_org_sintef_thingml_Connector				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
						startIncompleteElement(element);
					}
					if (a6_0 != null) {
						if (a6_0 != null) {
							Object value = a6_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.CONFIGURATION__CONNECTORS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_7_0_1_0, a6_0, true);
						copyLocalizationInfos(a6_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1568]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1569]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1570]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1571]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1572]);
			}
			
			
			|			(
				a7_0 = parse_org_sintef_thingml_ConfigInclude				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
						startIncompleteElement(element);
					}
					if (a7_0 != null) {
						if (a7_0 != null) {
							Object value = a7_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.CONFIGURATION__CONFIGS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_7_0_2_0, a7_0, true);
						copyLocalizationInfos(a7_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1573]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1574]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1575]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1576]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1577]);
			}
			
			
			|			(
				a8_0 = parse_org_sintef_thingml_ConfigPropertyAssign				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
						startIncompleteElement(element);
					}
					if (a8_0 != null) {
						if (a8_0 != null) {
							Object value = a8_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.CONFIGURATION__PROPASSIGNS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_7_0_3_0, a8_0, true);
						copyLocalizationInfos(a8_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1578]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1579]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1580]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1581]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1582]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1583]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1584]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1585]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1586]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1587]);
	}
	
	a9 = '}' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_20_0_0_9, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a9, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1588]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1589]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1590]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThingMLModel(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1591]);
	}
	
;

parse_org_sintef_thingml_ConfigInclude returns [org.sintef.thingml.ConfigInclude element = null]
@init{
}
:
	a0 = 'group' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigInclude();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_21_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1592]);
	}
	
	(
		a1 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigInclude();
				startIncompleteElement(element);
			}
			if (a1 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_INCLUDE__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_INCLUDE__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_21_0_0_2, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1593]);
	}
	
	a2 = ':' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigInclude();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_21_0_0_4, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1594]);
	}
	
	(
		a3 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigInclude();
				startIncompleteElement(element);
			}
			if (a3 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a3.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_INCLUDE__CONFIG), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a3).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Configuration proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfiguration();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.ConfigInclude, org.sintef.thingml.Configuration>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getConfigIncludeConfigReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_INCLUDE__CONFIG), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_INCLUDE__CONFIG), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_21_0_0_6, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigInclude(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1595]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1596]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1597]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1598]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1599]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1600]);
	}
	
	(
		(
			(
				a4_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigInclude();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.CONFIG_INCLUDE__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_21_0_0_7_0_0_0, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigInclude(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1601]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1602]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1603]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1604]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1605]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1606]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigInclude(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1607]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1608]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1609]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1610]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1611]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1612]);
	}
	
;

parse_org_sintef_thingml_Instance returns [org.sintef.thingml.Instance element = null]
@init{
}
:
	a0 = 'instance' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstance();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_22_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1613]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1614]);
	}
	
	(
		(
			(
				a1 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstance();
						startIncompleteElement(element);
					}
					if (a1 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE__NAME), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
						}
						java.lang.String resolved = (java.lang.String) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE__NAME), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_22_0_0_2_0_0_0, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1615]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1616]);
	}
	
	a2 = ':' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstance();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_22_0_0_3, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1617]);
	}
	
	(
		a3 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstance();
				startIncompleteElement(element);
			}
			if (a3 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a3.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE__TYPE), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a3).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Thing proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Instance, org.sintef.thingml.Thing>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getInstanceTypeReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE__TYPE), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE__TYPE), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_22_0_0_5, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInstance(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1618]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1619]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1620]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1621]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1622]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1623]);
	}
	
	(
		(
			(
				a4_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstance();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.INSTANCE__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_22_0_0_6_0_0_0, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInstance(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1624]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1625]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1626]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1627]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1628]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1629]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getInstance(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1630]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1631]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1632]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1633]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1634]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1635]);
	}
	
;

parse_org_sintef_thingml_Connector returns [org.sintef.thingml.Connector element = null]
@init{
}
:
	a0 = 'connector' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1636]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1637]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1638]);
	}
	
	(
		(
			(
				a1 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
						startIncompleteElement(element);
					}
					if (a1 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a1.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__NAME), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a1).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a1).getStopIndex());
						}
						java.lang.String resolved = (java.lang.String) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__NAME), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_2_0_0_0, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a1, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1639]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1640]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1641]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1642]);
	}
	
	(
		a2_0 = parse_org_sintef_thingml_InstanceRef		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
				startIncompleteElement(element);
			}
			if (a2_0 != null) {
				if (a2_0 != null) {
					Object value = a2_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__CLI), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_3, a2_0, true);
				copyLocalizationInfos(a2_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1643]);
	}
	
	a3 = '.' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_4, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1644]);
	}
	
	(
		a4 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
				startIncompleteElement(element);
			}
			if (a4 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a4.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__REQUIRED), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a4).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.RequiredPort proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Connector, org.sintef.thingml.RequiredPort>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getConnectorRequiredReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__REQUIRED), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__REQUIRED), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_5, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1645]);
	}
	
	a5 = '=>' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_6, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1646]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1647]);
	}
	
	(
		a6_0 = parse_org_sintef_thingml_InstanceRef		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
				startIncompleteElement(element);
			}
			if (a6_0 != null) {
				if (a6_0 != null) {
					Object value = a6_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__SRV), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_7, a6_0, true);
				copyLocalizationInfos(a6_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1648]);
	}
	
	a7 = '.' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_8, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1649]);
	}
	
	(
		a8 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
				startIncompleteElement(element);
			}
			if (a8 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a8.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__PROVIDED), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a8).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a8).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a8).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a8).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.ProvidedPort proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProvidedPort();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.Connector, org.sintef.thingml.ProvidedPort>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getConnectorProvidedReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__PROVIDED), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONNECTOR__PROVIDED), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_9, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a8, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a8, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1650]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1651]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1652]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1653]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1654]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1655]);
	}
	
	(
		(
			(
				a9_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConnector();
						startIncompleteElement(element);
					}
					if (a9_0 != null) {
						if (a9_0 != null) {
							Object value = a9_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.CONNECTOR__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_23_0_0_10_0_0_1, a9_0, true);
						copyLocalizationInfos(a9_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1656]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1657]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1658]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1659]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1660]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1661]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConnector(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1662]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1663]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1664]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1665]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1666]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1667]);
	}
	
;

parse_org_sintef_thingml_ConfigPropertyAssign returns [org.sintef.thingml.ConfigPropertyAssign element = null]
@init{
}
:
	a0 = 'set' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1668]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1669]);
	}
	
	(
		a1_0 = parse_org_sintef_thingml_InstanceRef		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
				startIncompleteElement(element);
			}
			if (a1_0 != null) {
				if (a1_0 != null) {
					Object value = a1_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_PROPERTY_ASSIGN__INSTANCE), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_1, a1_0, true);
				copyLocalizationInfos(a1_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1670]);
	}
	
	a2 = '.' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1671]);
	}
	
	(
		a3 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
				startIncompleteElement(element);
			}
			if (a3 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a3.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_PROPERTY_ASSIGN__PROPERTY), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a3).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a3).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Property proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createProperty();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.ConfigPropertyAssign, org.sintef.thingml.Property>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getConfigPropertyAssignPropertyReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_PROPERTY_ASSIGN__PROPERTY), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_PROPERTY_ASSIGN__PROPERTY), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_3, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a3, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1672]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1673]);
	}
	
	(
		(
			a4 = '[' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_4_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1674]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1675]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1676]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1677]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1678]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1679]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1680]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1681]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1682]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1683]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1684]);
			}
			
			(
				a5_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
						startIncompleteElement(element);
					}
					if (a5_0 != null) {
						if (a5_0 != null) {
							Object value = a5_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.CONFIG_PROPERTY_ASSIGN__INDEX, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_4_0_0_1, a5_0, true);
						copyLocalizationInfos(a5_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1685]);
			}
			
			a6 = ']' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_4_0_0_2, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a6, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1686]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1687]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1688]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1689]);
	}
	
	a7 = '=' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_6, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1690]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1691]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1692]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1693]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1694]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1695]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1696]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1697]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1698]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1699]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfigPropertyAssign(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1700]);
	}
	
	(
		a8_0 = parse_org_sintef_thingml_Expression		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigPropertyAssign();
				startIncompleteElement(element);
			}
			if (a8_0 != null) {
				if (a8_0 != null) {
					Object value = a8_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONFIG_PROPERTY_ASSIGN__INIT), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_24_0_0_8, a8_0, true);
				copyLocalizationInfos(a8_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1701]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1702]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1703]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConfiguration(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1704]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1705]);
	}
	
;

parse_org_sintef_thingml_InstanceRef returns [org.sintef.thingml.InstanceRef element = null]
@init{
}
:
	(
		(
			(
				a0 = TEXT				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstanceRef();
						startIncompleteElement(element);
					}
					if (a0 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE_REF__CONFIG), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
						}
						String resolved = (String) resolvedObject;
						org.sintef.thingml.ConfigInclude proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConfigInclude();
						collectHiddenTokens(element);
						registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.InstanceRef, org.sintef.thingml.ConfigInclude>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getInstanceRefConfigReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE_REF__CONFIG), resolved, proxy);
						if (proxy != null) {
							Object value = proxy;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.INSTANCE_REF__CONFIG, value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_25_0_0_0_0_0_0, proxy, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, proxy);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1706]);
			}
			
			a1 = '.' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstanceRef();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_25_0_0_0_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1707]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1708]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1709]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1710]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstanceRef();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE_REF__INSTANCE), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Instance proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createInstance();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.InstanceRef, org.sintef.thingml.Instance>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getInstanceRefInstanceReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE_REF__INSTANCE), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INSTANCE_REF__INSTANCE), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_25_0_0_1, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1711]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1712]);
	}
	
;

parse_org_sintef_thingml_SendAction returns [org.sintef.thingml.SendAction element = null]
@init{
}
:
	(
		a0 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createSendAction();
				startIncompleteElement(element);
			}
			if (a0 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.SEND_ACTION__PORT), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Port proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createRequiredPort();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.SendAction, org.sintef.thingml.Port>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getSendActionPortReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.SEND_ACTION__PORT), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.SEND_ACTION__PORT), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_26_0_0_0, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1713]);
	}
	
	a1 = '!' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createSendAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_26_0_0_1, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1714]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createSendAction();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.SEND_ACTION__MESSAGE), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Message proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMessage();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.SendAction, org.sintef.thingml.Message>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getSendActionMessageReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.SEND_ACTION__MESSAGE), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.SEND_ACTION__MESSAGE), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_26_0_0_2, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1715]);
	}
	
	a3 = '(' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createSendAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_26_0_0_3, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1716]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1717]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1718]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1719]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1720]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1721]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1722]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1723]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1724]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1725]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1726]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1727]);
	}
	
	(
		(
			(
				a4_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createSendAction();
						startIncompleteElement(element);
					}
					if (a4_0 != null) {
						if (a4_0 != null) {
							Object value = a4_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.SEND_ACTION__PARAMETERS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_26_0_0_4_0_0_0, a4_0, true);
						copyLocalizationInfos(a4_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1728]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1729]);
			}
			
			(
				(
					a5 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createSendAction();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_26_0_0_4_0_0_1_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1730]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1731]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1732]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1733]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1734]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1735]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1736]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1737]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1738]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1739]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getSendAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1740]);
					}
					
					(
						a6_0 = parse_org_sintef_thingml_Expression						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createSendAction();
								startIncompleteElement(element);
							}
							if (a6_0 != null) {
								if (a6_0 != null) {
									Object value = a6_0;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.SEND_ACTION__PARAMETERS, value);
									completedElement(value, true);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_26_0_0_4_0_0_1_0_0_2, a6_0, true);
								copyLocalizationInfos(a6_0, element);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1741]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1742]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1743]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1744]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1745]);
	}
	
	a7 = ')' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createSendAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_26_0_0_5, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1746]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1747]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1748]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1749]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1750]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1751]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1752]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1753]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1754]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1755]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1756]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1757]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1758]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1759]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1760]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1761]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1762]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1763]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1764]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1765]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1766]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1767]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1768]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1769]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1770]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1771]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1772]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1773]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1774]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1775]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1776]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1777]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1778]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1779]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1780]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1781]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1782]);
	}
	
;

parse_org_sintef_thingml_VariableAssignment returns [org.sintef.thingml.VariableAssignment element = null]
@init{
}
:
	(
		a0 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createVariableAssignment();
				startIncompleteElement(element);
			}
			if (a0 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.VARIABLE_ASSIGNMENT__PROPERTY), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Variable proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.VariableAssignment, org.sintef.thingml.Variable>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getVariableAssignmentPropertyReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.VARIABLE_ASSIGNMENT__PROPERTY), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.VARIABLE_ASSIGNMENT__PROPERTY), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_27_0_0_0, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1783]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1784]);
	}
	
	(
		(
			a1 = '[' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createVariableAssignment();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_27_0_0_2_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1785]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1786]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1787]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1788]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1789]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1790]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1791]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1792]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1793]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1794]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1795]);
			}
			
			(
				a2_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createVariableAssignment();
						startIncompleteElement(element);
					}
					if (a2_0 != null) {
						if (a2_0 != null) {
							Object value = a2_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.VARIABLE_ASSIGNMENT__INDEX, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_27_0_0_2_0_0_1, a2_0, true);
						copyLocalizationInfos(a2_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1796]);
			}
			
			a3 = ']' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createVariableAssignment();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_27_0_0_2_0_0_2, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1797]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1798]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1799]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1800]);
	}
	
	a4 = '=' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createVariableAssignment();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_27_0_0_3, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a4, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1801]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1802]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1803]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1804]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1805]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1806]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1807]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1808]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1809]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1810]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getVariableAssignment(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1811]);
	}
	
	(
		a5_0 = parse_org_sintef_thingml_Expression		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createVariableAssignment();
				startIncompleteElement(element);
			}
			if (a5_0 != null) {
				if (a5_0 != null) {
					Object value = a5_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.VARIABLE_ASSIGNMENT__EXPRESSION), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_27_0_0_5, a5_0, true);
				copyLocalizationInfos(a5_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1812]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1813]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1814]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1815]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1816]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1817]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1818]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1819]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1820]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1821]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1822]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1823]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1824]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1825]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1826]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1827]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1828]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1829]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1830]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1831]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1832]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1833]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1834]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1835]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1836]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1837]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1838]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1839]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1840]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1841]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1842]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1843]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1844]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1845]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1846]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1847]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1848]);
	}
	
;

parse_org_sintef_thingml_ActionBlock returns [org.sintef.thingml.ActionBlock element = null]
@init{
}
:
	a0 = 'do' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createActionBlock();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_28_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1849]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1850]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1851]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1852]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1853]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1854]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1855]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1856]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1857]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1858]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1859]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1860]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1861]);
	}
	
	(
		(
			(
				a1_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createActionBlock();
						startIncompleteElement(element);
					}
					if (a1_0 != null) {
						if (a1_0 != null) {
							Object value = a1_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.ACTION_BLOCK__ACTIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_28_0_0_1_0_0_1, a1_0, true);
						copyLocalizationInfos(a1_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1862]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1863]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1864]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1865]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1866]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1867]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1868]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1869]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1870]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1871]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1872]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1873]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1874]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1875]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1876]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1877]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1878]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1879]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1880]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1881]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1882]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1883]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1884]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1885]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1886]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1887]);
	}
	
	a2 = 'end' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createActionBlock();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_28_0_0_3, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1888]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1889]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1890]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1891]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1892]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1893]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1894]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1895]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1896]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1897]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1898]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1899]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1900]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1901]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1902]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1903]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1904]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1905]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1906]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1907]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1908]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1909]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1910]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1911]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1912]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1913]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1914]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1915]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1916]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1917]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1918]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1919]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1920]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1921]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1922]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1923]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1924]);
	}
	
;

parse_org_sintef_thingml_LocalVariable returns [org.sintef.thingml.LocalVariable element = null]
@init{
}
:
	(
		(
			(
				a0 = T_READONLY				
				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
						startIncompleteElement(element);
					}
					if (a0 != null) {
						org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("T_READONLY");
						tokenResolver.setOptions(getOptions());
						org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
						tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__CHANGEABLE), result);
						Object resolvedObject = result.getResolvedToken();
						if (resolvedObject == null) {
							addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
						}
						java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
						if (resolved != null) {
							Object value = resolved;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__CHANGEABLE), value);
							completedElement(value, false);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_1_0_0_0, resolved, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1925]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1926]);
	}
	
	a1 = 'var' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1927]);
	}
	
	(
		a2 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
				startIncompleteElement(element);
			}
			if (a2 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__NAME), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__NAME), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_4, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1928]);
	}
	
	a3 = ':' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_6, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1929]);
	}
	
	(
		a4 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
				startIncompleteElement(element);
			}
			if (a4 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a4.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__TYPE), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a4).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a4).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Type proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createThing();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.TypedElement, org.sintef.thingml.Type>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getTypedElementTypeReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__TYPE), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__TYPE), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_8, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a4, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1930]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1931]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1932]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1933]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1934]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1935]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1936]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1937]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1938]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1939]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1940]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1941]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1942]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1943]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1944]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1945]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1946]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1947]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1948]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1949]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1950]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1951]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1952]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1953]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1954]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1955]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1956]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1957]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1958]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1959]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1960]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1961]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1962]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1963]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1964]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1965]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1966]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1967]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1968]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1969]);
	}
	
	(
		(
			a5 = '[' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_9_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1970]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1971]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1972]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1973]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1974]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1975]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1976]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1977]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1978]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1979]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1980]);
			}
			
			(
				a6_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
						startIncompleteElement(element);
					}
					if (a6_0 != null) {
						if (a6_0 != null) {
							Object value = a6_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__CARDINALITY), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_9_0_0_1, a6_0, true);
						copyLocalizationInfos(a6_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1981]);
			}
			
			a7 = ']' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_9_0_0_2, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a7, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1982]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1983]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1984]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1985]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1986]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1987]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1988]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1989]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1990]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1991]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1992]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1993]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1994]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1995]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1996]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1997]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1998]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[1999]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2000]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2001]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2002]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2003]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2004]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2005]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2006]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2007]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2008]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2009]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2010]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2011]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2012]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2013]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2014]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2015]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2016]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2017]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2018]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2019]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2020]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2021]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2022]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2023]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2024]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2025]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2026]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2027]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2028]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2029]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2030]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2031]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2032]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2033]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2034]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2035]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2036]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2037]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2038]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2039]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2040]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2041]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2042]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2043]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2044]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2045]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2046]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2047]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2048]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2049]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2050]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2051]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2052]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2053]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2054]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2055]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2056]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2057]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2058]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2059]);
	}
	
	(
		(
			a8 = '=' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_10_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a8, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2060]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2061]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2062]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2063]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2064]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2065]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2066]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2067]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2068]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2069]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2070]);
			}
			
			(
				a9_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
						startIncompleteElement(element);
					}
					if (a9_0 != null) {
						if (a9_0 != null) {
							Object value = a9_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__INIT), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_10_0_0_3, a9_0, true);
						copyLocalizationInfos(a9_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2071]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2072]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2073]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2074]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2075]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2076]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2077]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2078]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2079]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2080]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2081]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2082]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2083]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2084]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2085]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2086]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2087]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2088]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2089]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2090]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2091]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2092]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2093]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2094]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2095]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2096]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2097]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2098]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2099]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2100]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2101]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2102]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2103]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2104]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2105]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2106]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2107]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2108]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2109]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2110]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2111]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2112]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2113]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2114]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2115]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2116]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2117]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2118]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2119]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2120]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2121]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2122]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2123]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2124]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2125]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2126]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2127]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2128]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2129]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2130]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2131]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2132]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2133]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2134]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2135]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2136]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2137]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2138]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2139]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2140]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2141]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2142]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2143]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2144]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2145]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2146]);
	}
	
	(
		(
			(
				a10_0 = parse_org_sintef_thingml_PlatformAnnotation				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLocalVariable();
						startIncompleteElement(element);
					}
					if (a10_0 != null) {
						if (a10_0 != null) {
							Object value = a10_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.LOCAL_VARIABLE__ANNOTATIONS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_29_0_0_11_0_0_0, a10_0, true);
						copyLocalizationInfos(a10_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2147]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2148]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2149]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2150]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2151]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2152]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2153]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2154]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2155]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2156]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2157]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2158]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2159]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2160]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2161]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2162]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2163]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2164]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2165]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2166]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2167]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2168]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2169]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2170]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2171]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2172]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2173]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2174]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2175]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2176]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2177]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2178]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2179]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2180]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2181]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2182]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2183]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2184]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLocalVariable(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2185]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2186]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2187]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2188]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2189]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2190]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2191]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2192]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2193]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2194]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2195]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2196]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2197]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2198]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2199]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2200]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2201]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2202]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2203]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2204]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2205]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2206]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2207]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2208]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2209]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2210]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2211]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2212]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2213]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2214]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2215]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2216]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2217]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2218]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2219]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2220]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2221]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2222]);
	}
	
;

parse_org_sintef_thingml_ExternStatement returns [org.sintef.thingml.ExternStatement element = null]
@init{
}
:
	(
		a0 = STRING_EXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExternStatement();
				startIncompleteElement(element);
			}
			if (a0 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("STRING_EXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EXTERN_STATEMENT__STATEMENT), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
				}
				java.lang.String resolved = (java.lang.String) resolvedObject;
				if (resolved != null) {
					Object value = resolved;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EXTERN_STATEMENT__STATEMENT), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_30_0_0_0, resolved, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2223]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2224]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2225]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2226]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2227]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2228]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2229]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2230]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2231]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2232]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2233]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2234]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2235]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2236]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2237]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2238]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2239]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2240]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2241]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2242]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2243]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2244]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2245]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2246]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2247]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2248]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2249]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2250]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2251]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2252]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2253]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2254]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2255]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2256]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2257]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2258]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2259]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2260]);
	}
	
	(
		(
			a1 = '&' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExternStatement();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_30_0_0_1_0_0_0, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2261]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2262]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2263]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2264]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2265]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2266]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2267]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2268]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2269]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2270]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2271]);
			}
			
			(
				a2_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExternStatement();
						startIncompleteElement(element);
					}
					if (a2_0 != null) {
						if (a2_0 != null) {
							Object value = a2_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.EXTERN_STATEMENT__SEGMENTS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_30_0_0_1_0_0_1, a2_0, true);
						copyLocalizationInfos(a2_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2272]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2273]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2274]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2275]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2276]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2277]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2278]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2279]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2280]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2281]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2282]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2283]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2284]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2285]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2286]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2287]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2288]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2289]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2290]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2291]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2292]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2293]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2294]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2295]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2296]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2297]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2298]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2299]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2300]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2301]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2302]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2303]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2304]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2305]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2306]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2307]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2308]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2309]);
			}
			
		)
		
	)*	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2310]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2311]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2312]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2313]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2314]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2315]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2316]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2317]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2318]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2319]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2320]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2321]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2322]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2323]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2324]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2325]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2326]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2327]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2328]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2329]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2330]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2331]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2332]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2333]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2334]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2335]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2336]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2337]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2338]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2339]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2340]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2341]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2342]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2343]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2344]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2345]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2346]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2347]);
	}
	
;

parse_org_sintef_thingml_ConditionalAction returns [org.sintef.thingml.ConditionalAction element = null]
@init{
}
:
	a0 = 'if' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConditionalAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_31_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2348]);
	}
	
	a1 = '(' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConditionalAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_31_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2349]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2350]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2351]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2352]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2353]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2354]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2355]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2356]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2357]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2358]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2359]);
	}
	
	(
		a2_0 = parse_org_sintef_thingml_Expression		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConditionalAction();
				startIncompleteElement(element);
			}
			if (a2_0 != null) {
				if (a2_0 != null) {
					Object value = a2_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONDITIONAL_ACTION__CONDITION), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_31_0_0_4, a2_0, true);
				copyLocalizationInfos(a2_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2360]);
	}
	
	a3 = ')' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConditionalAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_31_0_0_6, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2361]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2362]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2363]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2364]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2365]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2366]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2367]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2368]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2369]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2370]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2371]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2372]);
	}
	
	(
		a4_0 = parse_org_sintef_thingml_Action		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConditionalAction();
				startIncompleteElement(element);
			}
			if (a4_0 != null) {
				if (a4_0 != null) {
					Object value = a4_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONDITIONAL_ACTION__ACTION), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_31_0_0_8, a4_0, true);
				copyLocalizationInfos(a4_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2373]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2374]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2375]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2376]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2377]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2378]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2379]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2380]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2381]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2382]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2383]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2384]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2385]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2386]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2387]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2388]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2389]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2390]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2391]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2392]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2393]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2394]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2395]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2396]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2397]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2398]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2399]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2400]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2401]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2402]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2403]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2404]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2405]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2406]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2407]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2408]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2409]);
	}
	
	(
		(
			a5 = 'else' {
				if (element == null) {
					element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConditionalAction();
					startIncompleteElement(element);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_31_0_0_9_0_0_1, null, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
			}
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2410]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2411]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2412]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2413]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2414]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2415]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2416]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2417]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2418]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2419]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2420]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getConditionalAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2421]);
			}
			
			(
				a6_0 = parse_org_sintef_thingml_Action				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createConditionalAction();
						startIncompleteElement(element);
					}
					if (a6_0 != null) {
						if (a6_0 != null) {
							Object value = a6_0;
							element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.CONDITIONAL_ACTION__ELSE_ACTION), value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_31_0_0_9_0_0_3, a6_0, true);
						copyLocalizationInfos(a6_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2422]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2423]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2424]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2425]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2426]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2427]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2428]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2429]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2430]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2431]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2432]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2433]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2434]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2435]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2436]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2437]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2438]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2439]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2440]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2441]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2442]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2443]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2444]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2445]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2446]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2447]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2448]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2449]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2450]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2451]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2452]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2453]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2454]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2455]);
				addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2456]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2457]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2458]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2459]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2460]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2461]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2462]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2463]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2464]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2465]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2466]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2467]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2468]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2469]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2470]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2471]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2472]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2473]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2474]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2475]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2476]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2477]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2478]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2479]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2480]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2481]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2482]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2483]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2484]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2485]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2486]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2487]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2488]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2489]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2490]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2491]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2492]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2493]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2494]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2495]);
	}
	
;

parse_org_sintef_thingml_LoopAction returns [org.sintef.thingml.LoopAction element = null]
@init{
}
:
	a0 = 'while' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLoopAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_32_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2496]);
	}
	
	a1 = '(' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLoopAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_32_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2497]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2498]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2499]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2500]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2501]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2502]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2503]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2504]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2505]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2506]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2507]);
	}
	
	(
		a2_0 = parse_org_sintef_thingml_Expression		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLoopAction();
				startIncompleteElement(element);
			}
			if (a2_0 != null) {
				if (a2_0 != null) {
					Object value = a2_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOOP_ACTION__CONDITION), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_32_0_0_4, a2_0, true);
				copyLocalizationInfos(a2_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2508]);
	}
	
	a3 = ')' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLoopAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_32_0_0_6, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2509]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2510]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2511]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2512]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2513]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2514]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2515]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2516]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2517]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2518]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2519]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLoopAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2520]);
	}
	
	(
		a4_0 = parse_org_sintef_thingml_Action		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLoopAction();
				startIncompleteElement(element);
			}
			if (a4_0 != null) {
				if (a4_0 != null) {
					Object value = a4_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOOP_ACTION__ACTION), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_32_0_0_8, a4_0, true);
				copyLocalizationInfos(a4_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2521]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2522]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2523]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2524]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2525]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2526]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2527]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2528]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2529]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2530]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2531]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2532]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2533]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2534]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2535]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2536]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2537]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2538]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2539]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2540]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2541]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2542]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2543]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2544]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2545]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2546]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2547]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2548]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2549]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2550]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2551]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2552]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2553]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2554]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2555]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2556]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2557]);
	}
	
;

parse_org_sintef_thingml_PrintAction returns [org.sintef.thingml.PrintAction element = null]
@init{
}
:
	a0 = 'print' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPrintAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_33_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2558]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2559]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2560]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2561]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2562]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2563]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2564]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2565]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2566]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2567]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPrintAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2568]);
	}
	
	(
		a1_0 = parse_org_sintef_thingml_Expression		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPrintAction();
				startIncompleteElement(element);
			}
			if (a1_0 != null) {
				if (a1_0 != null) {
					Object value = a1_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PRINT_ACTION__MSG), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_33_0_0_2, a1_0, true);
				copyLocalizationInfos(a1_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2569]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2570]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2571]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2572]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2573]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2574]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2575]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2576]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2577]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2578]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2579]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2580]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2581]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2582]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2583]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2584]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2585]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2586]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2587]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2588]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2589]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2590]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2591]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2592]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2593]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2594]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2595]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2596]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2597]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2598]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2599]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2600]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2601]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2602]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2603]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2604]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2605]);
	}
	
;

parse_org_sintef_thingml_ErrorAction returns [org.sintef.thingml.ErrorAction element = null]
@init{
}
:
	a0 = 'error' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createErrorAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_34_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2606]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2607]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2608]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2609]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2610]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2611]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2612]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2613]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2614]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2615]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getErrorAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2616]);
	}
	
	(
		a1_0 = parse_org_sintef_thingml_Expression		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createErrorAction();
				startIncompleteElement(element);
			}
			if (a1_0 != null) {
				if (a1_0 != null) {
					Object value = a1_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ERROR_ACTION__MSG), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_34_0_0_2, a1_0, true);
				copyLocalizationInfos(a1_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2617]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2618]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2619]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2620]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2621]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2622]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2623]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2624]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2625]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2626]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2627]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2628]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2629]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2630]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2631]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2632]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2633]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2634]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2635]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2636]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2637]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2638]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2639]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2640]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2641]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2642]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2643]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2644]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2645]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2646]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2647]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2648]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2649]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2650]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2651]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2652]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2653]);
	}
	
;

parse_org_sintef_thingml_ReturnAction returns [org.sintef.thingml.ReturnAction element = null]
@init{
}
:
	a0 = 'return' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createReturnAction();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_35_0_0_0, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2654]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2655]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2656]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2657]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2658]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2659]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2660]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2661]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2662]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2663]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getReturnAction(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2664]);
	}
	
	(
		a1_0 = parse_org_sintef_thingml_Expression		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createReturnAction();
				startIncompleteElement(element);
			}
			if (a1_0 != null) {
				if (a1_0 != null) {
					Object value = a1_0;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.RETURN_ACTION__EXP), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_35_0_0_2, a1_0, true);
				copyLocalizationInfos(a1_0, element);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2665]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2666]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2667]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2668]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2669]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2670]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2671]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2672]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2673]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2674]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2675]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2676]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2677]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2678]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2679]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2680]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2681]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2682]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2683]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2684]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2685]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2686]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2687]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2688]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2689]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2690]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2691]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2692]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2693]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2694]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2695]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2696]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2697]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2698]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2699]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2700]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2701]);
	}
	
;

parse_org_sintef_thingml_FunctionCallStatement returns [org.sintef.thingml.FunctionCallStatement element = null]
@init{
}
:
	(
		a0 = TEXT		
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallStatement();
				startIncompleteElement(element);
			}
			if (a0 != null) {
				org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
				tokenResolver.setOptions(getOptions());
				org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
				tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_STATEMENT__FUNCTION), result);
				Object resolvedObject = result.getResolvedToken();
				if (resolvedObject == null) {
					addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
				}
				String resolved = (String) resolvedObject;
				org.sintef.thingml.Function proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
				collectHiddenTokens(element);
				registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.FunctionCall, org.sintef.thingml.Function>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getFunctionCallFunctionReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_STATEMENT__FUNCTION), resolved, proxy);
				if (proxy != null) {
					Object value = proxy;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_STATEMENT__FUNCTION), value);
					completedElement(value, false);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_36_0_0_0, proxy, true);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
				copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, proxy);
			}
		}
	)
	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2702]);
	}
	
	a1 = '(' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallStatement();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_36_0_0_1, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2703]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2704]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2705]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2706]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2707]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2708]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2709]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2710]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2711]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2712]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2713]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2714]);
	}
	
	(
		(
			(
				a2_0 = parse_org_sintef_thingml_Expression				{
					if (terminateParsing) {
						throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
					}
					if (element == null) {
						element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallStatement();
						startIncompleteElement(element);
					}
					if (a2_0 != null) {
						if (a2_0 != null) {
							Object value = a2_0;
							addObjectToList(element, org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_STATEMENT__PARAMETERS, value);
							completedElement(value, true);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_36_0_0_2_0_0_0, a2_0, true);
						copyLocalizationInfos(a2_0, element);
					}
				}
			)
			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2715]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2716]);
			}
			
			(
				(
					a3 = ',' {
						if (element == null) {
							element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallStatement();
							startIncompleteElement(element);
						}
						collectHiddenTokens(element);
						retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_36_0_0_2_0_0_1_0_0_0, null, true);
						copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
					}
					{
						// expected elements (follow set)
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2717]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2718]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2719]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2720]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2721]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2722]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2723]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2724]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2725]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2726]);
						addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallStatement(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2727]);
					}
					
					(
						a4_0 = parse_org_sintef_thingml_Expression						{
							if (terminateParsing) {
								throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
							}
							if (element == null) {
								element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallStatement();
								startIncompleteElement(element);
							}
							if (a4_0 != null) {
								if (a4_0 != null) {
									Object value = a4_0;
									addObjectToList(element, org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_STATEMENT__PARAMETERS, value);
									completedElement(value, true);
								}
								collectHiddenTokens(element);
								retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_36_0_0_2_0_0_1_0_0_2, a4_0, true);
								copyLocalizationInfos(a4_0, element);
							}
						}
					)
					{
						// expected elements (follow set)
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2728]);
						addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2729]);
					}
					
				)
				
			)*			{
				// expected elements (follow set)
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2730]);
				addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2731]);
			}
			
		)
		
	)?	{
		// expected elements (follow set)
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2732]);
	}
	
	a5 = ')' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallStatement();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_36_0_0_3, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2733]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2734]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2735]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2736]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2737]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2738]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2739]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2740]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getThing(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2741]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2742]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2743]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2744]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2745]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2746]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getStateMachine(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2747]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2748]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2749]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2750]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2751]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2752]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2753]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2754]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2755]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2756]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2757]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2758]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2759]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2760]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2761]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2762]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2763]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2764]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2765]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2766]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2767]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2768]);
		addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2769]);
	}
	
;

parseop_Expression_level_1 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
	leftArg = parseop_Expression_level_2	((
		()
		{ element = null; }
		a0 = 'or' {
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createOrExpression();
				startIncompleteElement(element);
			}
			collectHiddenTokens(element);
			retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_37_0_0_2, null, true);
			copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
		}
		{
			// expected elements (follow set)
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2770]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2771]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2772]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2773]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2774]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2775]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2776]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2777]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2778]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2779]);
			addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getOrExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2780]);
		}
		
		rightArg = parseop_Expression_level_2		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createOrExpression();
				startIncompleteElement(element);
			}
			if (leftArg != null) {
				if (leftArg != null) {
					Object value = leftArg;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.OR_EXPRESSION__LHS), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_37_0_0_0, leftArg, true);
				copyLocalizationInfos(leftArg, element);
			}
		}
		{
			if (terminateParsing) {
				throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
			}
			if (element == null) {
				element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createOrExpression();
				startIncompleteElement(element);
			}
			if (rightArg != null) {
				if (rightArg != null) {
					Object value = rightArg;
					element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.OR_EXPRESSION__RHS), value);
					completedElement(value, true);
				}
				collectHiddenTokens(element);
				retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_37_0_0_4, rightArg, true);
				copyLocalizationInfos(rightArg, element);
			}
		}
		{ leftArg = element; /* this may become an argument in the next iteration */ }
	)+ | /* epsilon */ { element = leftArg; }
	
)
;

parseop_Expression_level_2 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
leftArg = parseop_Expression_level_3((
	()
	{ element = null; }
	a0 = 'and' {
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createAndExpression();
			startIncompleteElement(element);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_38_0_0_2, null, true);
		copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
	}
	{
		// expected elements (follow set)
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2781]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2782]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2783]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2784]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2785]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2786]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2787]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2788]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2789]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2790]);
		addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getAndExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2791]);
	}
	
	rightArg = parseop_Expression_level_3	{
		if (terminateParsing) {
			throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
		}
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createAndExpression();
			startIncompleteElement(element);
		}
		if (leftArg != null) {
			if (leftArg != null) {
				Object value = leftArg;
				element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.AND_EXPRESSION__LHS), value);
				completedElement(value, true);
			}
			collectHiddenTokens(element);
			retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_38_0_0_0, leftArg, true);
			copyLocalizationInfos(leftArg, element);
		}
	}
	{
		if (terminateParsing) {
			throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
		}
		if (element == null) {
			element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createAndExpression();
			startIncompleteElement(element);
		}
		if (rightArg != null) {
			if (rightArg != null) {
				Object value = rightArg;
				element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.AND_EXPRESSION__RHS), value);
				completedElement(value, true);
			}
			collectHiddenTokens(element);
			retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_38_0_0_4, rightArg, true);
			copyLocalizationInfos(rightArg, element);
		}
	}
	{ leftArg = element; /* this may become an argument in the next iteration */ }
)+ | /* epsilon */ { element = leftArg; }

)
;

parseop_Expression_level_3 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
leftArg = parseop_Expression_level_4((
()
{ element = null; }
a0 = '<' {
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLowerExpression();
		startIncompleteElement(element);
	}
	collectHiddenTokens(element);
	retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_39_0_0_2, null, true);
	copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
	// expected elements (follow set)
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2792]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2793]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2794]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2795]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2796]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2797]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2798]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2799]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2800]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2801]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getLowerExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2802]);
}

rightArg = parseop_Expression_level_4{
	if (terminateParsing) {
		throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
	}
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLowerExpression();
		startIncompleteElement(element);
	}
	if (leftArg != null) {
		if (leftArg != null) {
			Object value = leftArg;
			element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOWER_EXPRESSION__LHS), value);
			completedElement(value, true);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_39_0_0_0, leftArg, true);
		copyLocalizationInfos(leftArg, element);
	}
}
{
	if (terminateParsing) {
		throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
	}
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createLowerExpression();
		startIncompleteElement(element);
	}
	if (rightArg != null) {
		if (rightArg != null) {
			Object value = rightArg;
			element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.LOWER_EXPRESSION__RHS), value);
			completedElement(value, true);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_39_0_0_4, rightArg, true);
		copyLocalizationInfos(rightArg, element);
	}
}
{ leftArg = element; /* this may become an argument in the next iteration */ }
|
()
{ element = null; }
a0 = '>' {
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createGreaterExpression();
		startIncompleteElement(element);
	}
	collectHiddenTokens(element);
	retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_40_0_0_2, null, true);
	copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
	// expected elements (follow set)
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2803]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2804]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2805]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2806]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2807]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2808]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2809]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2810]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2811]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2812]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getGreaterExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2813]);
}

rightArg = parseop_Expression_level_4{
	if (terminateParsing) {
		throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
	}
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createGreaterExpression();
		startIncompleteElement(element);
	}
	if (leftArg != null) {
		if (leftArg != null) {
			Object value = leftArg;
			element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.GREATER_EXPRESSION__LHS), value);
			completedElement(value, true);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_40_0_0_0, leftArg, true);
		copyLocalizationInfos(leftArg, element);
	}
}
{
	if (terminateParsing) {
		throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
	}
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createGreaterExpression();
		startIncompleteElement(element);
	}
	if (rightArg != null) {
		if (rightArg != null) {
			Object value = rightArg;
			element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.GREATER_EXPRESSION__RHS), value);
			completedElement(value, true);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_40_0_0_4, rightArg, true);
		copyLocalizationInfos(rightArg, element);
	}
}
{ leftArg = element; /* this may become an argument in the next iteration */ }
|
()
{ element = null; }
a0 = '==' {
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEqualsExpression();
		startIncompleteElement(element);
	}
	collectHiddenTokens(element);
	retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_41_0_0_2, null, true);
	copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
	// expected elements (follow set)
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2814]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2815]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2816]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2817]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2818]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2819]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2820]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2821]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2822]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2823]);
	addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getEqualsExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2824]);
}

rightArg = parseop_Expression_level_4{
	if (terminateParsing) {
		throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
	}
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEqualsExpression();
		startIncompleteElement(element);
	}
	if (leftArg != null) {
		if (leftArg != null) {
			Object value = leftArg;
			element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EQUALS_EXPRESSION__LHS), value);
			completedElement(value, true);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_41_0_0_0, leftArg, true);
		copyLocalizationInfos(leftArg, element);
	}
}
{
	if (terminateParsing) {
		throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
	}
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEqualsExpression();
		startIncompleteElement(element);
	}
	if (rightArg != null) {
		if (rightArg != null) {
			Object value = rightArg;
			element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EQUALS_EXPRESSION__RHS), value);
			completedElement(value, true);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_41_0_0_4, rightArg, true);
		copyLocalizationInfos(rightArg, element);
	}
}
{ leftArg = element; /* this may become an argument in the next iteration */ }
)+ | /* epsilon */ { element = leftArg; }

)
;

parseop_Expression_level_4 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
leftArg = parseop_Expression_level_5((
()
{ element = null; }
a0 = '+' {
if (element == null) {
	element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPlusExpression();
	startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_42_0_0_2, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2825]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2826]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2827]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2828]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2829]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2830]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2831]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2832]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2833]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2834]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getPlusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2835]);
}

rightArg = parseop_Expression_level_5{
if (terminateParsing) {
	throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
	element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPlusExpression();
	startIncompleteElement(element);
}
if (leftArg != null) {
	if (leftArg != null) {
		Object value = leftArg;
		element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PLUS_EXPRESSION__LHS), value);
		completedElement(value, true);
	}
	collectHiddenTokens(element);
	retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_42_0_0_0, leftArg, true);
	copyLocalizationInfos(leftArg, element);
}
}
{
if (terminateParsing) {
	throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
	element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPlusExpression();
	startIncompleteElement(element);
}
if (rightArg != null) {
	if (rightArg != null) {
		Object value = rightArg;
		element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PLUS_EXPRESSION__RHS), value);
		completedElement(value, true);
	}
	collectHiddenTokens(element);
	retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_42_0_0_4, rightArg, true);
	copyLocalizationInfos(rightArg, element);
}
}
{ leftArg = element; /* this may become an argument in the next iteration */ }
|
()
{ element = null; }
a0 = '-' {
if (element == null) {
	element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMinusExpression();
	startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_43_0_0_2, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2836]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2837]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2838]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2839]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2840]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2841]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2842]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2843]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2844]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2845]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getMinusExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2846]);
}

rightArg = parseop_Expression_level_5{
if (terminateParsing) {
	throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
	element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMinusExpression();
	startIncompleteElement(element);
}
if (leftArg != null) {
	if (leftArg != null) {
		Object value = leftArg;
		element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.MINUS_EXPRESSION__LHS), value);
		completedElement(value, true);
	}
	collectHiddenTokens(element);
	retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_43_0_0_0, leftArg, true);
	copyLocalizationInfos(leftArg, element);
}
}
{
if (terminateParsing) {
	throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
	element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createMinusExpression();
	startIncompleteElement(element);
}
if (rightArg != null) {
	if (rightArg != null) {
		Object value = rightArg;
		element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.MINUS_EXPRESSION__RHS), value);
		completedElement(value, true);
	}
	collectHiddenTokens(element);
	retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_43_0_0_4, rightArg, true);
	copyLocalizationInfos(rightArg, element);
}
}
{ leftArg = element; /* this may become an argument in the next iteration */ }
)+ | /* epsilon */ { element = leftArg; }

)
;

parseop_Expression_level_5 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
leftArg = parseop_Expression_level_6((
()
{ element = null; }
a0 = '*' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTimesExpression();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_44_0_0_2, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2847]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2848]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2849]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2850]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2851]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2852]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2853]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2854]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2855]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2856]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getTimesExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2857]);
}

rightArg = parseop_Expression_level_6{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTimesExpression();
startIncompleteElement(element);
}
if (leftArg != null) {
if (leftArg != null) {
	Object value = leftArg;
	element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TIMES_EXPRESSION__LHS), value);
	completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_44_0_0_0, leftArg, true);
copyLocalizationInfos(leftArg, element);
}
}
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createTimesExpression();
startIncompleteElement(element);
}
if (rightArg != null) {
if (rightArg != null) {
	Object value = rightArg;
	element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.TIMES_EXPRESSION__RHS), value);
	completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_44_0_0_4, rightArg, true);
copyLocalizationInfos(rightArg, element);
}
}
{ leftArg = element; /* this may become an argument in the next iteration */ }
|
()
{ element = null; }
a0 = '/' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createDivExpression();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_45_0_0_2, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2858]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2859]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2860]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2861]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2862]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2863]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2864]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2865]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2866]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2867]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getDivExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2868]);
}

rightArg = parseop_Expression_level_6{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createDivExpression();
startIncompleteElement(element);
}
if (leftArg != null) {
if (leftArg != null) {
	Object value = leftArg;
	element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.DIV_EXPRESSION__LHS), value);
	completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_45_0_0_0, leftArg, true);
copyLocalizationInfos(leftArg, element);
}
}
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createDivExpression();
startIncompleteElement(element);
}
if (rightArg != null) {
if (rightArg != null) {
	Object value = rightArg;
	element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.DIV_EXPRESSION__RHS), value);
	completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_45_0_0_4, rightArg, true);
copyLocalizationInfos(rightArg, element);
}
}
{ leftArg = element; /* this may become an argument in the next iteration */ }
)+ | /* epsilon */ { element = leftArg; }

)
;

parseop_Expression_level_6 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
leftArg = parseop_Expression_level_7((
a0 = '\u0025' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createModExpression();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_46_0_0_2, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2869]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2870]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2871]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2872]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2873]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2874]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2875]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2876]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2877]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2878]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getModExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2879]);
}

rightArg = parseop_Expression_level_6{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createModExpression();
startIncompleteElement(element);
}
if (leftArg != null) {
if (leftArg != null) {
Object value = leftArg;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.MOD_EXPRESSION__LHS), value);
completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_46_0_0_0, leftArg, true);
copyLocalizationInfos(leftArg, element);
}
}
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createModExpression();
startIncompleteElement(element);
}
if (rightArg != null) {
if (rightArg != null) {
Object value = rightArg;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.MOD_EXPRESSION__RHS), value);
completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_46_0_0_4, rightArg, true);
copyLocalizationInfos(rightArg, element);
}
}
) | /* epsilon */ { element = leftArg; }

)
;

parseop_Expression_level_7 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
a0 = '-' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createUnaryMinus();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_47_0_0_0, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2880]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2881]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2882]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2883]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2884]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2885]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2886]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2887]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2888]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2889]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getUnaryMinus(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2890]);
}

arg = parseop_Expression_level_8{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createUnaryMinus();
startIncompleteElement(element);
}
if (arg != null) {
if (arg != null) {
Object value = arg;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.UNARY_MINUS__TERM), value);
completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_47_0_0_1, arg, true);
copyLocalizationInfos(arg, element);
}
}
|
a0 = 'not' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createNotExpression();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_48_0_0_0, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2891]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2892]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2893]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2894]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2895]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2896]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2897]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2898]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2899]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2900]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getNotExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2901]);
}

arg = parseop_Expression_level_8{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createNotExpression();
startIncompleteElement(element);
}
if (arg != null) {
if (arg != null) {
Object value = arg;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.NOT_EXPRESSION__TERM), value);
completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_48_0_0_2, arg, true);
copyLocalizationInfos(arg, element);
}
}
|

arg = parseop_Expression_level_8{ element = arg; }
;

parseop_Expression_level_8 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
arg = parseop_Expression_level_9(
a0 = '[' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createArrayIndex();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_56_0_0_1, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2902]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2903]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2904]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2905]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2906]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2907]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2908]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2909]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2910]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2911]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getArrayIndex(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2912]);
}

(
a1_0 = parse_org_sintef_thingml_Expression{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createArrayIndex();
startIncompleteElement(element);
}
if (a1_0 != null) {
if (a1_0 != null) {
Object value = a1_0;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ARRAY_INDEX__INDEX), value);
completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_56_0_0_2, a1_0, true);
copyLocalizationInfos(a1_0, element);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2913]);
}

a2 = ']' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createArrayIndex();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_56_0_0_3, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
}
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2914]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2915]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2916]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2917]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2918]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2919]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2920]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2921]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2922]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2923]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2924]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2925]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2926]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2927]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2928]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2929]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2930]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2931]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2932]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2933]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2934]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2935]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2936]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2937]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2938]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2939]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2940]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2941]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2942]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2943]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2944]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2945]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2946]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2947]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2948]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2949]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2950]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2951]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2952]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2953]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2954]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2955]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2956]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2957]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2958]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2959]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2960]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2961]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2962]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2963]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2964]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2965]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2966]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2967]);
}

{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createArrayIndex();
startIncompleteElement(element);
}
if (arg != null) {
if (arg != null) {
Object value = arg;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ARRAY_INDEX__ARRAY), value);
completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_56_0_0_0, arg, true);
copyLocalizationInfos(arg, element);
}
}
|
/* epsilon */ { element = arg; } 
)
;

parseop_Expression_level_9 returns [org.sintef.thingml.Expression element = null]
@init{
}
:
c0 = parse_org_sintef_thingml_EventReference{ element = c0; /* this is a subclass or primitive expression choice */ }
|c1 = parse_org_sintef_thingml_ExpressionGroup{ element = c1; /* this is a subclass or primitive expression choice */ }
|c2 = parse_org_sintef_thingml_PropertyReference{ element = c2; /* this is a subclass or primitive expression choice */ }
|c3 = parse_org_sintef_thingml_IntegerLiteral{ element = c3; /* this is a subclass or primitive expression choice */ }
|c4 = parse_org_sintef_thingml_StringLiteral{ element = c4; /* this is a subclass or primitive expression choice */ }
|c5 = parse_org_sintef_thingml_BooleanLiteral{ element = c5; /* this is a subclass or primitive expression choice */ }
|c6 = parse_org_sintef_thingml_EnumLiteralRef{ element = c6; /* this is a subclass or primitive expression choice */ }
|c7 = parse_org_sintef_thingml_FunctionCallExpression{ element = c7; /* this is a subclass or primitive expression choice */ }
|c8 = parse_org_sintef_thingml_ExternExpression{ element = c8; /* this is a subclass or primitive expression choice */ }
;

parse_org_sintef_thingml_EventReference returns [org.sintef.thingml.EventReference element = null]
@init{
}
:
(
a0 = TEXT
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEventReference();
startIncompleteElement(element);
}
if (a0 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EVENT_REFERENCE__MSG_REF), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
}
String resolved = (String) resolvedObject;
org.sintef.thingml.ReceiveMessage proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createReceiveMessage();
collectHiddenTokens(element);
registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.EventReference, org.sintef.thingml.ReceiveMessage>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getEventReferenceMsgRefReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EVENT_REFERENCE__MSG_REF), resolved, proxy);
if (proxy != null) {
Object value = proxy;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EVENT_REFERENCE__MSG_REF), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_49_0_0_0, proxy, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, proxy);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2968]);
}

a1 = '.' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEventReference();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_49_0_0_1, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
}
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2969]);
}

(
a2 = TEXT
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEventReference();
startIncompleteElement(element);
}
if (a2 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EVENT_REFERENCE__PARAM_REF), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
}
String resolved = (String) resolvedObject;
org.sintef.thingml.Parameter proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
collectHiddenTokens(element);
registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.EventReference, org.sintef.thingml.Parameter>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getEventReferenceParamRefReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EVENT_REFERENCE__PARAM_REF), resolved, proxy);
if (proxy != null) {
Object value = proxy;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EVENT_REFERENCE__PARAM_REF), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_49_0_0_2, proxy, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, proxy);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2970]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2971]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2972]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2973]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2974]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2975]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2976]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2977]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2978]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2979]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2980]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2981]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2982]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2983]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2984]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2985]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2986]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2987]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2988]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2989]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2990]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2991]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2992]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2993]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2994]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2995]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2996]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2997]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2998]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[2999]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3000]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3001]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3002]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3003]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3004]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3005]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3006]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3007]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3008]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3009]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3010]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3011]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3012]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3013]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3014]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3015]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3016]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3017]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3018]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3019]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3020]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3021]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3022]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3023]);
}

;

parse_org_sintef_thingml_ExpressionGroup returns [org.sintef.thingml.ExpressionGroup element = null]
@init{
}
:
a0 = '(' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExpressionGroup();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_50_0_0_0, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a0, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3024]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3025]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3026]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3027]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3028]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3029]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3030]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3031]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3032]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3033]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExpressionGroup(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3034]);
}

(
a1_0 = parse_org_sintef_thingml_Expression{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExpressionGroup();
startIncompleteElement(element);
}
if (a1_0 != null) {
if (a1_0 != null) {
Object value = a1_0;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EXPRESSION_GROUP__EXP), value);
completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_50_0_0_1, a1_0, true);
copyLocalizationInfos(a1_0, element);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3035]);
}

a2 = ')' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExpressionGroup();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_50_0_0_2, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a2, element);
}
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3036]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3037]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3038]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3039]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3040]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3041]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3042]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3043]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3044]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3045]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3046]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3047]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3048]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3049]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3050]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3051]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3052]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3053]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3054]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3055]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3056]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3057]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3058]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3059]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3060]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3061]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3062]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3063]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3064]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3065]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3066]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3067]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3068]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3069]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3070]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3071]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3072]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3073]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3074]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3075]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3076]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3077]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3078]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3079]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3080]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3081]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3082]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3083]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3084]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3085]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3086]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3087]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3088]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3089]);
}

;

parse_org_sintef_thingml_PropertyReference returns [org.sintef.thingml.PropertyReference element = null]
@init{
}
:
(
a0 = TEXT
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createPropertyReference();
startIncompleteElement(element);
}
if (a0 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY_REFERENCE__PROPERTY), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
}
String resolved = (String) resolvedObject;
org.sintef.thingml.Variable proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createParameter();
collectHiddenTokens(element);
registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.PropertyReference, org.sintef.thingml.Variable>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getPropertyReferencePropertyReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY_REFERENCE__PROPERTY), resolved, proxy);
if (proxy != null) {
Object value = proxy;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.PROPERTY_REFERENCE__PROPERTY), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_51_0_0_0, proxy, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, proxy);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3090]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3091]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3092]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3093]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3094]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3095]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3096]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3097]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3098]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3099]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3100]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3101]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3102]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3103]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3104]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3105]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3106]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3107]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3108]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3109]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3110]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3111]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3112]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3113]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3114]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3115]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3116]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3117]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3118]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3119]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3120]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3121]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3122]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3123]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3124]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3125]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3126]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3127]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3128]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3129]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3130]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3131]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3132]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3133]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3134]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3135]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3136]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3137]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3138]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3139]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3140]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3141]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3142]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3143]);
}

;

parse_org_sintef_thingml_IntegerLiteral returns [org.sintef.thingml.IntegerLiteral element = null]
@init{
}
:
(
a0 = INTEGER_LITERAL
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createIntegerLiteral();
startIncompleteElement(element);
}
if (a0 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("INTEGER_LITERAL");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INTEGER_LITERAL__INT_VALUE), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
}
java.lang.Integer resolved = (java.lang.Integer) resolvedObject;
if (resolved != null) {
Object value = resolved;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.INTEGER_LITERAL__INT_VALUE), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_52_0_0_0, resolved, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3144]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3145]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3146]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3147]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3148]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3149]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3150]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3151]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3152]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3153]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3154]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3155]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3156]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3157]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3158]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3159]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3160]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3161]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3162]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3163]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3164]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3165]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3166]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3167]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3168]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3169]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3170]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3171]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3172]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3173]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3174]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3175]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3176]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3177]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3178]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3179]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3180]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3181]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3182]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3183]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3184]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3185]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3186]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3187]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3188]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3189]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3190]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3191]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3192]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3193]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3194]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3195]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3196]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3197]);
}

;

parse_org_sintef_thingml_StringLiteral returns [org.sintef.thingml.StringLiteral element = null]
@init{
}
:
(
a0 = STRING_LITERAL
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createStringLiteral();
startIncompleteElement(element);
}
if (a0 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("STRING_LITERAL");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STRING_LITERAL__STRING_VALUE), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
}
java.lang.String resolved = (java.lang.String) resolvedObject;
if (resolved != null) {
Object value = resolved;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.STRING_LITERAL__STRING_VALUE), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_53_0_0_0, resolved, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3198]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3199]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3200]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3201]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3202]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3203]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3204]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3205]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3206]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3207]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3208]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3209]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3210]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3211]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3212]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3213]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3214]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3215]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3216]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3217]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3218]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3219]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3220]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3221]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3222]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3223]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3224]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3225]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3226]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3227]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3228]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3229]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3230]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3231]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3232]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3233]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3234]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3235]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3236]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3237]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3238]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3239]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3240]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3241]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3242]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3243]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3244]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3245]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3246]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3247]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3248]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3249]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3250]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3251]);
}

;

parse_org_sintef_thingml_BooleanLiteral returns [org.sintef.thingml.BooleanLiteral element = null]
@init{
}
:
(
a0 = BOOLEAN_LITERAL
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createBooleanLiteral();
startIncompleteElement(element);
}
if (a0 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("BOOLEAN_LITERAL");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.BOOLEAN_LITERAL__BOOL_VALUE), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
}
java.lang.Boolean resolved = (java.lang.Boolean) resolvedObject;
if (resolved != null) {
Object value = resolved;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.BOOLEAN_LITERAL__BOOL_VALUE), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_54_0_0_0, resolved, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3252]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3253]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3254]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3255]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3256]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3257]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3258]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3259]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3260]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3261]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3262]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3263]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3264]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3265]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3266]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3267]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3268]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3269]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3270]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3271]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3272]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3273]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3274]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3275]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3276]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3277]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3278]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3279]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3280]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3281]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3282]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3283]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3284]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3285]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3286]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3287]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3288]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3289]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3290]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3291]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3292]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3293]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3294]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3295]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3296]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3297]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3298]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3299]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3300]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3301]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3302]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3303]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3304]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3305]);
}

;

parse_org_sintef_thingml_EnumLiteralRef returns [org.sintef.thingml.EnumLiteralRef element = null]
@init{
}
:
(
a0 = TEXT
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumLiteralRef();
startIncompleteElement(element);
}
if (a0 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUM_LITERAL_REF__ENUM), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
}
String resolved = (String) resolvedObject;
org.sintef.thingml.Enumeration proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumeration();
collectHiddenTokens(element);
registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.EnumLiteralRef, org.sintef.thingml.Enumeration>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getEnumLiteralRefEnumReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUM_LITERAL_REF__ENUM), resolved, proxy);
if (proxy != null) {
Object value = proxy;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUM_LITERAL_REF__ENUM), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_55_0_0_0, proxy, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, proxy);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3306]);
}

a1 = ':' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumLiteralRef();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_55_0_0_1, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
}
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3307]);
}

(
a2 = TEXT
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumLiteralRef();
startIncompleteElement(element);
}
if (a2 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a2.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUM_LITERAL_REF__LITERAL), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a2).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a2).getStopIndex());
}
String resolved = (String) resolvedObject;
org.sintef.thingml.EnumerationLiteral proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createEnumerationLiteral();
collectHiddenTokens(element);
registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.EnumLiteralRef, org.sintef.thingml.EnumerationLiteral>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getEnumLiteralRefLiteralReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUM_LITERAL_REF__LITERAL), resolved, proxy);
if (proxy != null) {
Object value = proxy;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.ENUM_LITERAL_REF__LITERAL), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_55_0_0_2, proxy, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, element);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a2, proxy);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3308]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3309]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3310]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3311]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3312]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3313]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3314]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3315]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3316]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3317]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3318]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3319]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3320]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3321]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3322]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3323]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3324]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3325]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3326]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3327]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3328]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3329]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3330]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3331]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3332]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3333]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3334]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3335]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3336]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3337]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3338]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3339]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3340]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3341]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3342]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3343]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3344]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3345]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3346]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3347]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3348]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3349]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3350]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3351]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3352]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3353]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3354]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3355]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3356]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3357]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3358]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3359]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3360]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3361]);
}

;

parse_org_sintef_thingml_FunctionCallExpression returns [org.sintef.thingml.FunctionCallExpression element = null]
@init{
}
:
(
a0 = TEXT
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallExpression();
startIncompleteElement(element);
}
if (a0 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("TEXT");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_EXPRESSION__FUNCTION), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
}
String resolved = (String) resolvedObject;
org.sintef.thingml.Function proxy = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunction();
collectHiddenTokens(element);
registerContextDependentProxy(new org.sintef.thingml.resource.thingml.mopp.ThingmlContextDependentURIFragmentFactory<org.sintef.thingml.FunctionCall, org.sintef.thingml.Function>(getReferenceResolverSwitch() == null ? null : getReferenceResolverSwitch().getFunctionCallFunctionReferenceResolver()), element, (org.eclipse.emf.ecore.EReference) element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_EXPRESSION__FUNCTION), resolved, proxy);
if (proxy != null) {
Object value = proxy;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_EXPRESSION__FUNCTION), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_57_0_0_0, proxy, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, proxy);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3362]);
}

a1 = '(' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallExpression();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_57_0_0_1, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3363]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3364]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3365]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3366]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3367]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3368]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3369]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3370]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3371]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3372]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3373]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3374]);
}

(
(
(
a2_0 = parse_org_sintef_thingml_Expression{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallExpression();
startIncompleteElement(element);
}
if (a2_0 != null) {
if (a2_0 != null) {
	Object value = a2_0;
	addObjectToList(element, org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_EXPRESSION__PARAMETERS, value);
	completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_57_0_0_2_0_0_0, a2_0, true);
copyLocalizationInfos(a2_0, element);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3375]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3376]);
}

(
(
a3 = ',' {
if (element == null) {
	element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallExpression();
	startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_57_0_0_2_0_0_1_0_0_0, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a3, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3377]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3378]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3379]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3380]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3381]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3382]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3383]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3384]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3385]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3386]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getFunctionCallExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3387]);
}

(
a4_0 = parse_org_sintef_thingml_Expression{
	if (terminateParsing) {
		throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
	}
	if (element == null) {
		element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallExpression();
		startIncompleteElement(element);
	}
	if (a4_0 != null) {
		if (a4_0 != null) {
			Object value = a4_0;
			addObjectToList(element, org.sintef.thingml.ThingmlPackage.FUNCTION_CALL_EXPRESSION__PARAMETERS, value);
			completedElement(value, true);
		}
		collectHiddenTokens(element);
		retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_57_0_0_2_0_0_1_0_0_2, a4_0, true);
		copyLocalizationInfos(a4_0, element);
	}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3388]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3389]);
}

)

)*{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3390]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3391]);
}

)

)?{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3392]);
}

a5 = ')' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createFunctionCallExpression();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_57_0_0_3, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a5, element);
}
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3393]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3394]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3395]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3396]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3397]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3398]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3399]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3400]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3401]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3402]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3403]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3404]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3405]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3406]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3407]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3408]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3409]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3410]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3411]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3412]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3413]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3414]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3415]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3416]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3417]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3418]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3419]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3420]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3421]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3422]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3423]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3424]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3425]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3426]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3427]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3428]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3429]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3430]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3431]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3432]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3433]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3434]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3435]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3436]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3437]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3438]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3439]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3440]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3441]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3442]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3443]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3444]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3445]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3446]);
}

;

parse_org_sintef_thingml_ExternExpression returns [org.sintef.thingml.ExternExpression element = null]
@init{
}
:
(
a0 = STRING_EXT
{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExternExpression();
startIncompleteElement(element);
}
if (a0 != null) {
org.sintef.thingml.resource.thingml.IThingmlTokenResolver tokenResolver = tokenResolverFactory.createTokenResolver("STRING_EXT");
tokenResolver.setOptions(getOptions());
org.sintef.thingml.resource.thingml.IThingmlTokenResolveResult result = getFreshTokenResolveResult();
tokenResolver.resolve(a0.getText(), element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EXTERN_EXPRESSION__EXPRESSION), result);
Object resolvedObject = result.getResolvedToken();
if (resolvedObject == null) {
addErrorToResource(result.getErrorMessage(), ((org.antlr.runtime3_4_0.CommonToken) a0).getLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getCharPositionInLine(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStartIndex(), ((org.antlr.runtime3_4_0.CommonToken) a0).getStopIndex());
}
java.lang.String resolved = (java.lang.String) resolvedObject;
if (resolved != null) {
Object value = resolved;
element.eSet(element.eClass().getEStructuralFeature(org.sintef.thingml.ThingmlPackage.EXTERN_EXPRESSION__EXPRESSION), value);
completedElement(value, false);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_58_0_0_0, resolved, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken) a0, element);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3447]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3448]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3449]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3450]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3451]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3452]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3453]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3454]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3455]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3456]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3457]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3458]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3459]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3460]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3461]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3462]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3463]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3464]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3465]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3466]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3467]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3468]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3469]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3470]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3471]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3472]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3473]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3474]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3475]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3476]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3477]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3478]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3479]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3480]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3481]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3482]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3483]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3484]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3485]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3486]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3487]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3488]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3489]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3490]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3491]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3492]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3493]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3494]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3495]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3496]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3497]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3498]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3499]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3500]);
}

(
(
a1 = '&' {
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExternExpression();
startIncompleteElement(element);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_58_0_0_1_0_0_0, null, true);
copyLocalizationInfos((org.antlr.runtime3_4_0.CommonToken)a1, element);
}
{
// expected elements (follow set)
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3501]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3502]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3503]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3504]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3505]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3506]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3507]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3508]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3509]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3510]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getExternExpression(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3511]);
}

(
a2_0 = parse_org_sintef_thingml_Expression{
if (terminateParsing) {
throw new org.sintef.thingml.resource.thingml.mopp.ThingmlTerminateParsingException();
}
if (element == null) {
element = org.sintef.thingml.ThingmlFactory.eINSTANCE.createExternExpression();
startIncompleteElement(element);
}
if (a2_0 != null) {
if (a2_0 != null) {
	Object value = a2_0;
	addObjectToList(element, org.sintef.thingml.ThingmlPackage.EXTERN_EXPRESSION__SEGMENTS, value);
	completedElement(value, true);
}
collectHiddenTokens(element);
retrieveLayoutInformation(element, org.sintef.thingml.resource.thingml.grammar.ThingmlGrammarInformationProvider.THINGML_58_0_0_1_0_0_1, a2_0, true);
copyLocalizationInfos(a2_0, element);
}
}
)
{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3512]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3513]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3514]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3515]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3516]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3517]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3518]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3519]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3520]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3521]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3522]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3523]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3524]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3525]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3526]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3527]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3528]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3529]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3530]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3531]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3532]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3533]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3534]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3535]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3536]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3537]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3538]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3539]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3540]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3541]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3542]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3543]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3544]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3545]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3546]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3547]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3548]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3549]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3550]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3551]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3552]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3553]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3554]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3555]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3556]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3557]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3558]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3559]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3560]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3561]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3562]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3563]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3564]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3565]);
}

)

)*{
// expected elements (follow set)
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3566]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3567]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3568]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3569]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3570]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3571]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3572]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3573]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3574]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3575]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3576]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3577]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3578]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getCompositeState(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3579]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3580]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3581]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3582]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3583]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3584]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3585]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3586]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3587]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3588]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3589]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3590]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3591]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3592]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3593]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3594]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3595]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3596]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3597]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3598]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3599]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3600]);
addExpectedElement(org.sintef.thingml.ThingmlPackage.eINSTANCE.getActionBlock(), org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3601]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3602]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3603]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3604]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3605]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3606]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3607]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3608]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3609]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3610]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3611]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3612]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3613]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3614]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3615]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3616]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3617]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3618]);
addExpectedElement(null, org.sintef.thingml.resource.thingml.mopp.ThingmlExpectationConstants.EXPECTATIONS[3619]);
}

;

parse_org_sintef_thingml_Type returns [org.sintef.thingml.Type element = null]
:
c0 = parse_org_sintef_thingml_Thing{ element = c0; /* this is a subclass or primitive expression choice */ }
|c1 = parse_org_sintef_thingml_PrimitiveType{ element = c1; /* this is a subclass or primitive expression choice */ }
|c2 = parse_org_sintef_thingml_Enumeration{ element = c2; /* this is a subclass or primitive expression choice */ }

;

parse_org_sintef_thingml_Expression returns [org.sintef.thingml.Expression element = null]
:
c = parseop_Expression_level_1{ element = c; /* this rule is an expression root */ }

;

parse_org_sintef_thingml_Action returns [org.sintef.thingml.Action element = null]
:
c0 = parse_org_sintef_thingml_SendAction{ element = c0; /* this is a subclass or primitive expression choice */ }
|c1 = parse_org_sintef_thingml_VariableAssignment{ element = c1; /* this is a subclass or primitive expression choice */ }
|c2 = parse_org_sintef_thingml_ActionBlock{ element = c2; /* this is a subclass or primitive expression choice */ }
|c3 = parse_org_sintef_thingml_LocalVariable{ element = c3; /* this is a subclass or primitive expression choice */ }
|c4 = parse_org_sintef_thingml_ExternStatement{ element = c4; /* this is a subclass or primitive expression choice */ }
|c5 = parse_org_sintef_thingml_ConditionalAction{ element = c5; /* this is a subclass or primitive expression choice */ }
|c6 = parse_org_sintef_thingml_LoopAction{ element = c6; /* this is a subclass or primitive expression choice */ }
|c7 = parse_org_sintef_thingml_PrintAction{ element = c7; /* this is a subclass or primitive expression choice */ }
|c8 = parse_org_sintef_thingml_ErrorAction{ element = c8; /* this is a subclass or primitive expression choice */ }
|c9 = parse_org_sintef_thingml_ReturnAction{ element = c9; /* this is a subclass or primitive expression choice */ }
|c10 = parse_org_sintef_thingml_FunctionCallStatement{ element = c10; /* this is a subclass or primitive expression choice */ }

;

parse_org_sintef_thingml_Port returns [org.sintef.thingml.Port element = null]
:
c0 = parse_org_sintef_thingml_RequiredPort{ element = c0; /* this is a subclass or primitive expression choice */ }
|c1 = parse_org_sintef_thingml_ProvidedPort{ element = c1; /* this is a subclass or primitive expression choice */ }

;

parse_org_sintef_thingml_Event returns [org.sintef.thingml.Event element = null]
:
c0 = parse_org_sintef_thingml_ReceiveMessage{ element = c0; /* this is a subclass or primitive expression choice */ }

;

SL_COMMENT:
('//'(~('\n'|'\r'|'\uffff'))* )
{ _channel = 99; }
;
ML_COMMENT:
('/*'.*'*/')
{ _channel = 99; }
;
ANNOTATION:
('@'('A'..'Z' | 'a'..'z' | '0'..'9' | '_' )+)
;
BOOLEAN_LITERAL:
('true'|'false')
;
INTEGER_LITERAL:
(('1'..'9') ('0'..'9')* | '0')
;
STRING_LITERAL:
('"'('\\'('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')|('\\''u'('0'..'9'|'a'..'f'|'A'..'F')('0'..'9'|'a'..'f'|'A'..'F')('0'..'9'|'a'..'f'|'A'..'F')('0'..'9'|'a'..'f'|'A'..'F'))|'\\'('0'..'7')|~('\\'|'"'))*'"')
;
STRING_EXT:
('\''('\\'('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')|('\\''u'('0'..'9'|'a'..'f'|'A'..'F')('0'..'9'|'a'..'f'|'A'..'F')('0'..'9'|'a'..'f'|'A'..'F')('0'..'9'|'a'..'f'|'A'..'F'))|'\\'('0'..'7')|~('\\'|'\''))*'\'')
;
T_READONLY:
('readonly')
;
T_OPTIONAL:
('optional')
;
T_ASPECT:
('fragment')
;
T_HISTORY:
('history')
;
WHITESPACE:
((' '|'\t'|'\f'))
{ _channel = 99; }
;
LINEBREAKS:
(('\r\n'|'\r'|'\n'))
{ _channel = 99; }
;
TEXT:
(('A'..'Z' | 'a'..'z' | '0'..'9' | '_' )+)
;
