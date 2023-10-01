/*
Form element attribute references
	class="validation-submit-entry" \\ Element to be disable if validation failed (eg. submit button)
	data-validation-rule="<rulename>" \\ Name to references in the validationRules file.
	data-validation-matching="<element name>" \\ Element name to test if the value matches. (eg. to test password and confirm password)
	data-validation-api-token="<api token>" \\ Token to passing to the API from headers.Authorization
	data-validation-is-exist-endpoint="<api endpoint url>" \\ API endpoint url to check data is exists
	data-validation-is-exist-self-id="<self objectId>" \\ Id to ignore when check the data is exists in update mode

IsExists validation API guide
	...
	const data = await model.find()
	if (data[0]) {
		// data is exists, Form-Validator raise an error
		return res.status(200).json({
			success: true,
			data: data
		})
	} else {
		// data is not exists, Form-Validator do nothing
		return res.status(404).json({
			success: false,
			data: []
		})		
	}

*/

import { rules } from './validationRules.js';

let characterSet = {
	uppercases: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
	lowercases: 'abcdefghijklmnopqrstuvwxyz',
	digits: '0123456789',
	symbols: '!@#$%^&?*()_+-=[]:;*,./<>≤',
};
characterSet.all =
	characterSet.uppercases +
	characterSet.lowercases +
	characterSet.digits +
	characterSet.symbols;

const WordCapitalize = function (content, force = false) {
	let words = [];

	words = content.split(/\_|\ |\r?\n|\r|\n/); // /\-|\_|\ |\r?\n|\r|\n/
	words = force
		? words.map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
		: words.map(word => word.charAt(0).toUpperCase() + word.slice(1));
	words = words.filter(word => word.trim() != '');
	words = words.join(' ');

	// Capitalize after ()
	words = words.split(/\(/); // /\-|\_|\ |\r?\n|\r|\n/
	words = words.map(word => word.charAt(0).toUpperCase() + word.slice(1));
	words = words.filter(word => word.trim() != '');
	words = words.join('(');

	return words;
};

const SentenceCapitalize = function (content, force = false) {
	let sentences = [];

	// Capitalize from spaces and wordbreaks
	sentences = content.split(/\./);
	sentences = force
		? sentences.map(
				sentence =>
					sentence.trim().charAt(0).toUpperCase() +
					sentence.trim().slice(1).toLowerCase()
		  )
		: sentences.map(
				sentence =>
					sentence.trim().charAt(0).toUpperCase() + sentence.trim().slice(1)
		  );
	sentences = sentences.join('. ').trim();

	return sentences;
};

const validateRule = async function (target, validationSubmitEntries) {
	const parentForm = target.closest('form');

	let matchingElement;
	let matchingElementMessageLabel;
	target.value = target.value.trim();

	const vr = target.validationRule;
	let foundError = false;

	validationSubmitEntries.forEach(entry => entry.setAttribute('disabled', ''));

	// Init & checking Min, Max
	if (vr) {
		if (target.minLength < 0 && vr.minLength) target.minLength = vr.minLength;
		if (target.maxLength < 0 && vr.maxLength) target.maxLength = vr.maxLength;

		if (target.minLength >= 0) vr.minLength = target.minLength;
		if (target.maxLength >= 0) vr.maxLength = target.maxLength;
	}

	let messageLabel = target.parentNode.querySelector('.fv-message-label');

	if (!messageLabel) {
		messageLabel = document.createElement('p');
		messageLabel.classList.add('fv-message-label');
		target.parentNode.insertAdjacentElement('beforeend', messageLabel);
	}

	if (!vr?.multipleSpaces != true) {
		target.value = target.value.replace(/\s+/g, ' ');
	}

	// Validate Allowed Spaces
	if (vr?.allowSpaces != true) {
		target.value = target.value.replace(/\s/g, '');
	}

	// Validate minlength
	if (!foundError) {
		if (vr?.minLength >= 0) {
			if (target.value.length < vr.minLength) {
				target.classList.add('error');
				messageLabel.classList.add('error');
				messageLabel.innerText = `${WordCapitalize(
					target.name
				)} must be at lease ${vr.minLength} character(s)!`;
				foundError = true;
				return;
			}
		}
	}

	// Validate maxlength
	if (!foundError) {
		if (vr?.maxLength > 0) {
			if (target.value.length > vr.maxLength) {
				target.classList.add('error');
				messageLabel.classList.add('error');
				messageLabel.innerText = `${WordCapitalize(
					target.name
				)} must be less than or equal ${vr.maxLength} character(s)!`;
				foundError = true;
				return;
			}
		}
	}

	// textTransform
	if (!foundError) {
		if (vr?.textTransform === 'lower') {
			target.value = target.value.toLowerCase();
		} else if (vr?.textTransform === 'upper') {
			target.value = target.value.toUpperCase();
		} else if (vr?.textTransform === 'sentenceCapitalize') {
			target.value = SentenceCapitalize(target.value);
		} else if (vr?.textTransform === 'sentenceCapitalize-force') {
			target.value = SentenceCapitalize(target.value, true);
		} else if (vr?.textTransform === 'wordCapitalize') {
			target.value = WordCapitalize(target.value);
		} else if (vr?.textTransform === 'wordCapitalize-force') {
			target.value = WordCapitalize(target.value, true);
		}
	}

	// Validate Allowed Character Set
	if (!foundError) {
		if (vr?.allowCharacterSet) {
			let allowedCharacters = '';
			let allowedCharactersHint = '';
			if (vr?.allowCharacterSet.all) {
				allowedCharacters += characterSet.all;
				allowedCharactersHint += `(A-Z), (a-z), (0-9), (${characterSet.symbols})`;
			} else {
				if (vr?.allowCharacterSet.uppercases) {
					allowedCharacters += characterSet.uppercases;
					allowedCharactersHint +=
						allowedCharactersHint === '' ? '(A-Z)' : ', (A-Z)';
				}
				if (vr?.allowCharacterSet.lowercases) {
					allowedCharacters += characterSet.lowercases;
					allowedCharactersHint +=
						allowedCharactersHint === '' ? '(a-z)' : ', (a-z)';
				}
				if (vr?.allowCharacterSet.digits) {
					allowedCharacters += characterSet.digits;
					allowedCharactersHint +=
						allowedCharactersHint === '' ? '(0-9)' : ', (0-9)';
				}
				if (vr?.allowCharacterSet.symbols) {
					allowedCharacters += characterSet.symbols;
					allowedCharactersHint +=
						allowedCharactersHint === ''
							? `(${characterSet.symbols})`
							: `, (${characterSet.symbols})`;
				}
				if (vr?.allowCharacterSet.custom) {
					allowedCharacters += vr?.allowCharacterSet.custom;
					allowedCharactersHint +=
						allowedCharactersHint === ''
							? `(${vr?.allowCharacterSet.custom})`
							: `, (${vr?.allowCharacterSet.custom})`;
				}
			}

			if (vr?.allowSpaces) allowedCharacters += ' ';
			if (vr?.multiline) allowedCharacters += '\n\r';

			// console.log('form-validator:::validateRules->allowedCharacters', allowedCharacters)

			target.value.split('').forEach(c => {
				if (!allowedCharacters.includes(c)) {
					target.classList.add('error');
					messageLabel.classList.add('error');
					messageLabel.innerText = `Forbidden character! ${allowedCharactersHint}`;
					foundError = true;
					return;
				}
			});
		}
	}

	// Check Min/Max for type=number
	if (target.type === 'number') {
		// console.log('form-validator:::validateRule->target.type="number"->target', target)
		if (!target.value) {
			target.value = target.min ? target.min : 0;
		} else {
			try {
				const floatValue = parseFloat(target.value);
				target.value = target.min
					? floatValue < target.min
						? target.min
						: target.value
					: target.value;
				target.value = target.max
					? floatValue > target.max
						? target.max
						: target.value
					: target.value;
			} catch (error) {
				target.value = target.min ? target.min : 0;
			}
		}
	}

	if (!foundError) {
		if (target.type === 'url') {
			// Try to re-format
			if (target.value.startsWith('www')) {
				target.value = `http://${target.value}`;
			}
			if (!target.value.startsWith('http')) {
				target.value = `http://www.${target.value}`;
			}
		}
	}

	// Validate Data is Exist
	if (!foundError) {
		const endpoint = target.dataset.validationIsExistEndpoint;
		const apiToken = target.dataset.validationApiToken;
		const selfId = target.dataset.validationIsExistSelfId;
		const targetValue = target.value;

		// console.log('form-validator:::validateRules->apiToken', apiToken)
		if (endpoint) {
			try {
				const res = await fetch(`${endpoint}/${targetValue}`, {
					method: 'GET',
					headers: {
						Authorization: apiToken,
					},
				});
				// console.log('form-validator:::validateRules->res', res)

				const data = await res.json();
				// console.log('form-validator:::validateRules->data', data)

				if (data.success && data.data[0]) {
					if (selfId) {
						data.data.forEach(object => {
							if (object._id != selfId) {
								target.classList.add('error');
								messageLabel.classList.add('error');
								// prettier-ignore
								messageLabel.innerText = `${WordCapitalize(target.name)} "${target.value}" is already EXIST!`
								foundError = true;
								return;
							}
						});
					} else {
						target.classList.add('error');
						messageLabel.classList.add('error');
						// prettier-ignore
						messageLabel.innerText = `${WordCapitalize(target.name)} "${target.value}" is already EXIST!`
						foundError = true;
						return;
					}
				}
			} catch (SyntaxError) {
				// console.log('form-validator:::validateRules->fetch.error', error)
				// pass
			}
		}
	}

	// Validate 2 fields value matching (eg. password and confirm password)
	if (!foundError) {
		if (target.dataset.validationMatching) {
			matchingElement = parentForm.querySelector(
				'[name="' + target.dataset.validationMatching + '"]'
			);
			if (matchingElement) {
				if (target.value && matchingElement.value) {
					let matchingElementMessageLabel =
						matchingElement.parentNode.querySelector('.fv-message-label');
					if (target.value != matchingElement.value) {
						matchingElement.classList.add('error');
						target.classList.add('error');
						messageLabel.classList.add('error');
						messageLabel.innerText = `${WordCapitalize(
							target.name
						)} and ${WordCapitalize(matchingElement.name)} not match!`;
						foundError = true;
						return;
					} else {
						matchingElement.classList.remove('error', 'warning');
						matchingElement.classList.add('success');
						target.classList.remove('error');
						if (matchingElementMessageLabel) {
							matchingElementMessageLabel.classList.remove('error');
							matchingElementMessageLabel.innerText = '';
						}
					}
				}
			}
		}
	}

	// Reset style and message
	if (!foundError) {
		target.classList.remove('error', 'warning');
		target.classList.add('success');
		messageLabel.classList.remove('error', 'warning');
		messageLabel.innerText = '';

		if (matchingElement) {
			matchingElement.classList.remove('error', 'warning');
			matchingElement.classList.add('success');

			matchingElementMessageLabel =
				matchingElement.parentNode.querySelector('.message-label');
			if (matchingElementMessageLabel) {
				matchingElementMessageLabel.classList.remove('error', 'warning');
				matchingElementMessageLabel.innerText = '';
			}
		}
	}

	// Reset validationSubmitEntries if no error left
	const errorElements = parentForm.querySelectorAll('.error');

	// console.log('form-validator:::validateRules->errorElements', errorElements)
	// console.log('form-validator:::validateRules->validationSubmitEntries', validationSubmitEntries)

	if (!errorElements[0] && validationSubmitEntries[0]) {
		validationSubmitEntries?.forEach(entry => {
			try {
				entry.removeAttribute('disabled');
			} catch (error) {
				// pass
			}
		});
	}
};

const assignRules = function () {
	const forms = document.querySelectorAll('form');

	if (forms) {
		forms.forEach(form => {
			const validationSubmitEntries = form.querySelectorAll(
				'.validation-submit-entry'
			);
			validationSubmitEntries.forEach(entry => entry.setAttribute('disabled', ''));

			const inputs = form.querySelectorAll('input');
			if (inputs) {
				inputs.forEach(input => {
					let rule = input.dataset?.validationRule ?? undefined;
					if (rule) {
						if (rules[rule].required) {
							input.setAttribute('Required', '');
						}
						input.validationRule = rules[rule];
						input.addEventListener('blur', e => {
							validateRule(input, validationSubmitEntries);
						});
					}
				});
			}

			const selects = form.querySelectorAll('select');
			if (selects) {
				selects.forEach(select => {
					let rule = select.dataset?.validationRule ?? undefined;
					if (rule) {
						select.validationRule = rules[rule];
						select.addEventListener('change', e => {
							validateRule(select, validationSubmitEntries);
						});
					}
				});
			}

			const textareas = form.querySelectorAll('textarea');
			if (textareas) {
				textareas.forEach(textarea => {
					let rule = textarea.dataset?.validationRule ?? undefined;
					if (rule) {
						if (rules[rule].required) {
							textareas.setAttribute('Required', '');
						}
						textarea.validationRule = rules[rule];
						textarea.addEventListener('blur', e => {
							validateRule(textarea, validationSubmitEntries);
						});
					}
				});
			}
		});
	}
};

assignRules();

export { assignRules };
