/*
*  Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
*  WSO2 Inc. licenses this file to you under the Apache License,
*  Version 2.0 (the "License"); you may not use this file except
*  in compliance with the License.
*  You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing,
*  software distributed under the License is distributed on an
*  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
*  KIND, either express or implied.  See the License for the
*  specific language governing permissions and limitations
*  under the License.
*/
package org.ballerinalang.langserver.completions;

import org.antlr.v4.runtime.InputMismatchException;
import org.antlr.v4.runtime.NoViableAltException;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.ballerinalang.langserver.compiler.DocumentServiceKeys;
import org.ballerinalang.langserver.compiler.LSContext;
import org.ballerinalang.langserver.compiler.common.LSCustomErrorStrategy;
import org.eclipse.lsp4j.Position;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.ballerinalang.compiler.parser.antlr4.BallerinaParser;

import java.util.Stack;

/**
 * Capture possible errors from source.
 */
public class CompletionCustomErrorStrategy extends LSCustomErrorStrategy {

    private static final Logger logger = LoggerFactory.getLogger(CompletionCustomErrorStrategy.class);

    private LSContext context;

    private int removeTokenCount = 0;

    private Stack<Token> forceConsumedTokens = new Stack<>();

    private Token lastTerminationToken = null;

    private Token firstTokenOfCursorLine = null;

    public CompletionCustomErrorStrategy(LSContext context) {
        super(context);
        this.context = context;
    }

    @Override
    public void reportInputMismatch(Parser parser, InputMismatchException e) {
        this.context.put(CompletionKeys.TOKEN_STREAM_KEY, parser.getTokenStream());
    }

    @Override
    public void reportMissingToken(Parser parser) {
        this.context.put(CompletionKeys.TOKEN_STREAM_KEY, parser.getTokenStream());
    }

    @Override
    public void reportNoViableAlternative(Parser parser, NoViableAltException e) {
        this.context.put(CompletionKeys.TOKEN_STREAM_KEY, parser.getTokenStream());
    }

    @Override
    public void reportUnwantedToken(Parser parser) {
        this.context.put(CompletionKeys.TOKEN_STREAM_KEY, parser.getTokenStream());
    }

    @Override
    public void reportMatch(Parser recognizer) {
        removePendingTokensAfterThisToken(recognizer, lastTerminationToken);
        super.reportMatch(recognizer);
        if (recognizer.getCurrentToken().getType() != BallerinaParser.EOF && isInLastTermination(recognizer)) {
            deleteTokensUpToCursor(recognizer, true);
        }
    }

    @Override
    public void sync(Parser recognizer) throws RecognitionException {
        removePendingTokensAfterThisToken(recognizer, lastTerminationToken);
        if (recognizer.getCurrentToken().getType() != BallerinaParser.EOF && isInFirstTokenOfCursorLine(recognizer)) {
            deleteTokensUpToCursor(recognizer, false);
        } else if (recognizer.getCurrentToken().getType() != BallerinaParser.EOF && isInLastTermination(recognizer)) {
            deleteTokensUpToCursor(recognizer, true);
        }
        super.sync(recognizer);
    }

    private void removePendingTokensAfterThisToken(Parser recognizer, Token token) {
        int currentTokenIndex = recognizer.getCurrentToken().getTokenIndex();
        if (token != null && currentTokenIndex <= token.getTokenIndex()) {
            return;
        }
        while (removeTokenCount > 0) {
            forceConsumedTokens.push(recognizer.consume());
            removeTokenCount--;
        }
        this.context.put(CompletionKeys.FORCE_CONSUMED_TOKENS_KEY, forceConsumedTokens);
    }

    private boolean isInFirstTokenOfCursorLine(Parser recognizer) {
        Token currentToken = recognizer.getCurrentToken();
        if (firstTokenOfCursorLine == null) {
            firstTokenOfCursorLine = getFirstTokenOfCursorLine(recognizer);
        }
        return firstTokenOfCursorLine != null && currentToken.getTokenIndex() == firstTokenOfCursorLine.getTokenIndex();
    }

    private boolean isInLastTermination(Parser recognizer) {
        Token currentToken = recognizer.getCurrentToken();
        if (lastTerminationToken == null) {
            lastTerminationToken = getLastTerminationToken(recognizer.getInputStream());
        }
        return lastTerminationToken != null && currentToken.getTokenIndex() == lastTerminationToken.getTokenIndex();
    }

    private void deleteTokensUpToCursor(Parser recognizer, boolean isInLastTermination) {
        Position cursorPosition = this.context.get(DocumentServiceKeys.POSITION_KEY).getPosition();
        int cursorLine = cursorPosition.getLine() + 1;
        int cursorCol = cursorPosition.getCharacter() + 1;

        int index = 1;
        Token beforeCursorToken = recognizer.getInputStream().LT(index);
        int type = beforeCursorToken.getType();
        int tLine = beforeCursorToken.getLine();
        int tCol = beforeCursorToken.getCharPositionInLine();

        int needToRemoveTokenCount = -1;
        while (type != BallerinaParser.EOF && ((tLine < cursorLine) || (tLine == cursorLine && tCol < cursorCol))) {
            index++;
            needToRemoveTokenCount++;
            beforeCursorToken = recognizer.getInputStream().LT(index);
            type = beforeCursorToken.getType();
            tLine = beforeCursorToken.getLine();
            tCol = beforeCursorToken.getCharPositionInLine();
        }

        if (isInLastTermination) {
            removeTokenCount = needToRemoveTokenCount;
        }
    }

    private Token getFirstTokenOfCursorLine(Parser recognizer) {
        TokenStream tokenStream = recognizer.getInputStream();
        Token firstCursorLineToken = null;
        int cursorLine = this.context.get(DocumentServiceKeys.POSITION_KEY).getPosition().getLine() + 1;
        int cursorCol = this.context.get(DocumentServiceKeys.POSITION_KEY).getPosition().getCharacter() + 1;

        int index = 1;
        Token beforeCursorToken = tokenStream.LT(index);
        int type = beforeCursorToken.getType();
        int tLine = beforeCursorToken.getLine();
        int tCol = beforeCursorToken.getCharPositionInLine();

        if (cursorLine < tLine || (cursorLine == tLine && cursorCol <= tCol)) {
            return null;
        }

        firstCursorLineToken = (tLine == cursorLine) ? beforeCursorToken : null;

        while (type != BallerinaParser.EOF && (tLine <= cursorLine)) {
            if (tLine == cursorLine) {
                firstCursorLineToken = beforeCursorToken;
            }
            index++;
            beforeCursorToken = tokenStream.LT(index);
            type = beforeCursorToken.getType();
            tLine = beforeCursorToken.getLine();
        }
        return firstCursorLineToken;
    }

    private Token getLastTerminationToken(TokenStream tokenStream) {
        Token lastTerminationToken = null;
        Position cursorPosition = this.context.get(DocumentServiceKeys.POSITION_KEY).getPosition();
        int cursorLine = cursorPosition.getLine() + 1;
        int cursorCol = cursorPosition.getCharacter() + 1;

        int index = 1;
        Token beforeCursorToken = tokenStream.LT(index);
        int type = beforeCursorToken.getType();
        int tLine = beforeCursorToken.getLine();
        int tCol = beforeCursorToken.getCharPositionInLine();

        while (type != BallerinaParser.EOF && ((tLine < cursorLine) || (tLine == cursorLine && tCol < cursorCol))) {
            if (beforeCursorToken.getTokenIndex() == 1 || type == BallerinaParser.SEMICOLON ||
                    type == BallerinaParser.LEFT_BRACE || type == BallerinaParser.RIGHT_BRACE ||
                    type == BallerinaParser.COMMA) {
                lastTerminationToken = beforeCursorToken;
            }
            index++;
            beforeCursorToken = tokenStream.LT(index);
            type = beforeCursorToken.getType();
            tLine = beforeCursorToken.getLine();
            tCol = beforeCursorToken.getCharPositionInLine();
        }
        return lastTerminationToken;
    }
}
