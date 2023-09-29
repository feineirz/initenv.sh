/*
========== Rules format ==========

allowCharacterSet references
	lowercases: 'abcdefghijklmnopqrstuvwxyz'
	uppercases: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	digits: '0123456789'
	symbols: '!@#$%^&?*()_+-=[]:;*,./<>≤'
	all: All of above
	custom: 'Any character specified here'

textTransform references
	upper: Turn all text to uppercase
	lower: Turn all text to lowercase
	wordCapitalize: Uppercase first letter of each word and ignore the left
	wordCapitalize-force: Uppercase first letter of each word and turns the left to lowercase
	SentenceCapitalize: Uppercase first letter of the sentence and ignore the left
	SentenceCapitalize-force: Uppercase first letter of the sentence and turns the left to lowercase

rules = {
    <rulename>: { // Name to refer from "data-validation-rule" attribute of form element
        minLength: <number>, // Minimum text length from "minlength" attribute of form element
        maxLength: <number>, // Maximum text length from "maxlength" attribute of form element
        allowSpaces: <true, false>, // Remove any space from input if set to false
        multiline: <true, false>, // Allow multi line if set to true else remove /n/r
        allowCharacterSet: {
            * See allowCharacterSet reference
        },
        textTransform: '<upper, lower, wordCapitalize, wordCapitalize-force, sentenceCapitalize, sentenceCapitalize-force>', // See textTransform references
    }
}
*/

export const rules = {
	sampleUsername: {
		minLength: 8,
		maxLength: 24,
		allowSpaces: false,
		allowCharacterSet: {
			lowercases: true,
		},
		textTransform: 'lower',
	},
};
