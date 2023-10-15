#! /bin/bash


########################## Functions ##########################
# Welcome screen
welcome() {
	clear
	echo "===== NODEJS-EXPRESS ENVIRONMENT INITAILIZE SCRIPT ====="
}

# Git Env
initGitEnv() {
	readmeFile=README.md
	licenseFile=LICENSE
	ignoreFile=.gitignore

	echo ""
	echo "== Initialize Git environment =="
	read -p "Repository name: " repoName
	read -p "Application name: " appName
	read -p "Branch name (main, master or anything): " branchName

	echo ""
	read -p "Clone from github repository(SSH)? (y/n): " cloneGithub

	if [ $cloneGithub = "y" ] ; then
		initGithub
	else
		initLocalGit
	fi

}

# Initialize Github repository
initGithub() {
	read -p "Github username: " ghUsername
	echo ""
	echo "== Initialize Github repository (SSH clone) =="
	git clone git@github.com:$ghUsername/$repoName.git
	cd $repoName

	currentBranch=$(git branch)

	# prepare basic files
	if [ ! -f "$readmeFile" ] ; then
		echo "# "$repoName >> README.md
	fi
	if [ ! -f "$licenseFile" ] ; then
		echo "# "$repoName" LICENSE" >> LICENSE
	fi
	if [ ! -f "$ignoreFile" ] ; then
		wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/.gitignore	
	fi

	git add .
	git commit -m "Start initialize"
	git push origin $currentBranch:$branchName
	echo "$currentBranch:$branchName"

	git branch -M $branchName
	git pull
	
}

# Initialize local GIT repository
initLocalGit() {
	mkdir $repoName
	cd $repoName
	echo "# "$repoName >> README.md
	echo "# "$repoName" LICENSE" >> LICENSE.md
	# .gitignore
	wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/.gitignore

	git init
	git branch -M $branchName	
}

# Initialize Prettier
initPrettier() {
	echo ""
	read -p "Use prettier? (y/n): " usePrettier
	if [ $usePrettier = "y" ] ; then
		echo "Installing prettier"

		npm i --save-dev prettier

		touch .prettierrc .prettierignore

		cat > .prettierrc << EOF
{
	"trailingComma": "es5",
	"semi": false,
	"singleQuote": true,
	"arrowParens": "avoid",
	"tabWidth": 4,
	"printWidth": 90
}
EOF

		cat > .prettierignore << EOF
# Ignore artifacts:
build
coverage

# Ignore all HTML files:
**/*.html

**/.git
**/.svn
**/.hg
**/node_modules
EOF
	fi	
}

# Create directory and file structure
initProjectStructure() {
	echo ""
	echo "== Generating NodeJS project structure =="

	touch app.js
		cat > app.js << EOF
// Initialize
require('dotenv').config()
const path = require('path')
const morgan = require('morgan')

const express = require('express')
// End Initialize


// App config
app.set('views', 'views')

app.use(express.urlencoded({ extended: true }))
app.use(express.json())

app.use(express.static(path.join(__dirname, 'public')))

// End App config


// Middlewares
app.use(morgan('dev'))
// End Middlewares


// Access-Control
app.use((req, res, next) => {
	res.header('Access-Control-Allow-Credentials', true)
	res.header('Access-Control-Allow-Origin', '*')
	res.header('Access-Control-Allow-Methods', 'POST, GET, PUT, PATCH, DELETE')
	res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization')

	next()
})

// Response local variables
app.use((req, res, next) => {
	// Response local variable list

	// End Response local variable list

	next()
})
// End Response local variables


// Routes
// End Routes


// Connect database and running the server
// End Connect database and running the server

EOF

	touch .env

	mkdir models views controllers routes apis auths middlewares utils config public
	mkdir public/images public/css public/js public/uploads routes/api

	cd config
	touch database.js server.js
	cd ..

	cd public/css
	touch main.css container.css nav.css form.css text.css colors.css decore.css
	cd ../..

}

# Installing common packages
installCommon() {
	echo ""
	echo "== Installing common packages =="
	echo "Installing dotenv bcryptjs @types/node randomstring nodemon morgan"
	npm i --save dotenv bcryptjs @types/node randomstring
	npm i --save-dev nodemon morgan
}

# Installing Express
installExpress() {
	echo "Installing express"
	npm i --save express
}

# Pick Main Stack
pickMainStack() {
	echo ""
	echo "== Pickup Main Stack =="
	echo "1. express mongoose"
	echo "2. express mysql2"
	read -p "Select stack: " mainStackId
}

# Initialize Session
initSession() {
	echo ""
	read -p "Use session? (y/n): " useSession
	if [ $useSession = "y" ] ; then
		echo "Installing express-session"
		npm i --save express-session
	fi

}

# Initialize MongoDB stack
initMongoDBStack() {
	cat > .env << EOF
MONGODB_URI = 'mongodb://127.0.0.1:27017/$repoName'

EOF
	
	echo "Installing mongoose"
	npm i --save mongoose
	sed -i "/\/\/ End Initialize/i \
const mongoose = require('mongoose')" app.js
	
	if [ $useSession = "y" ] ; then
		echo "Installing connect-mongodb-session"
		npm i --save connect-mongodb-session
		sed -i "/\/\/ End Initialize/i \
const session = require('express-session')\n\
const MongoDBStore = require('connect-mongodb-session')(session)\n\n\
const store = new MongoDBStore({\n\
	uri: process.env.MONGODB_URI,\n\
	collection: 'sessions'\n\
})\n\
store.on('error', error => {\n\
	console.log(error)\n\
	process.exit(1)\n\
})" app.js
	
		sed -i "/\/\/ Middlewares/a \
app.use(session({\n\
	secret: 'secret key',\n\
	cookie: {\n\
		maxAge: 1000 * 60 * 60 * 24 * 7 // 1 week\n\
	},\n\
	store: store,\n\
	resave: true,\n\
	saveUninitialized: true\n\
}))" app.js
	fi
	
	sed -i "/\/\/ Connect database and running the server/a \
const serverPort = process.env.PORT || 3000\n\
mongoose\n\
	.connect(process.env.MONGODB_URI)\n\
    .then(result => {\n\
		console.log('MongoDB database connected.')\n\n\
		app.listen(serverPort, result => {\n\
			console.log(\`Listening on port \${serverPort}...\`)\n\
		})\n\
    })\n\
    .catch(err => {\n\
		console.log('Error occurred while starting the server\!\!\!')\n\
		process.exit(3)\n\
    })" app.js
}

# Initialize MySQL stack
initMysqlStack() {
	cat > .env << EOF
MYSQL_HOST='127.0.0.1'
MYSQL_DATABASE='$repoName'
MYSQL_USER='root'
MYSQL_PASSWORD=''

EOF
	echo "Installing mysql2"
	npm i --save mysql2
	
	cat > config/database.js << EOF
const mysql = require('mysql2')
exports.connectionPool=mysql.createPool({
	host: process.env.MYSQL_HOST,
	database: process.env.MYSQL_DATABASE,
	user: process.env.MYSQL_USER,
	password: process.env.MYSQL_PASSWORD,
}).promise()
EOF
	
	if [ $useSession = "y" ] ; then
		sed -i "/\/\/ End Initialize/i \
const session = require('express-session')" app.js
	
		sed -i "/\/\/ Middlewares/a \
app.use(session({\n\
  	secret: 'secret key',\n\
	cookie: {\n\
		maxAge: 1000 * 60 * 60 * 24 * 7 // 1 week\n\
	},\n\
	resave: true,\n\
	saveUninitialized: true\n\
}))" app.js	
	fi
	
	sed -i "/\/\/ Connect database and running the server/a \
const serverPort = process.env.PORT || 3000\n\
app.listen(serverPort, result => {\n\
  console.log(\`Listening on port \${serverPort}...\`)\n\
})" app.js
}

# INitialize Main stack
initMainStack() {
	if [ $mainStackId = "1" ] ; then
		initMongoDBStack
	elif [ $mainStackId = "2" ] ; then
		initMysqlStack
	fi
}

# Initialize Connect-Flash + SweetAlert2
initFlashSwal() {
	if [ $useSession = "y" ] ; then
		echo ""
		read -p "Use Connect Flash and SweetAlert2? (y/n): " useFlashSwal
		if [ $useFlashSwal = "y" ] ; then
			echo "Installing connect-flash"
			npm i --save connect-flash
			sed -i "/\/\/ End Initialize/i \
const flash = require('connect-flash')" app.js

			sed -i "/\/\/ End Middlewares/i \
app.use(flash())" app.js

			cd public/css
			wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/connect-flash.css
			cd ../..
		fi
	fi	
}

# Multer and Sharp-Multer
initMulter() {
	echo ""
	read -p "Use Multer and Sharp-Multer? (y/n): " useMulter
	if [ $useMulter = "y" ] ; then
		echo "Installing multer sharp-multer"
		npm i --save multer sharp-multer

		mkdir public/uploads/files
		mkdir public/uploads/images
		touch public/uploads/files/.gitkeep
		touch public/uploads/images/.gitkeep


		# Multer middleware files
		cd middlewares
		wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/fileUploader.js
		wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/imageUploader.js
		cd ..
	fi	
}

# Initialize EJS
initEJS() {
	echo ""
	read -p "Use EJS view engine? (y/n): " useEJS
	if [ $useEJS = "y" ] ; then
		echo "Installing ejs..."
		npm i --save ejs

		sed -i "/app.set('views', 'views')/a \
app.set('view engine', 'ejs')" app.js

		sed -i "/\/\/ Response local variable list/a \
		res.locals.pageTitle = '$appName'" app.js

		mkdir views/partials
		cd views/partials
		touch head.ejs joint.ejs footer.ejs nav.ejs

		cat > head.ejs << EOF
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		<!-- Bootstrap 5.2 -->
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">

		<!-- Sweetalert2 -->
		<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

		<!-- Internal CSS -->
		<link rel="shortcut icon" href="images/favicon.png" type="image/x-icon">

		<link rel="stylesheet" href="css/main.css">
		<link rel="stylesheet" href="css/container.css">
		<link rel="stylesheet" href="css/nav.css">
		<link rel="stylesheet" href="css/form.css">
		<link rel="stylesheet" href="css/decore.css">
		<link rel="stylesheet" href="css/colors.css">
		<link rel="stylesheet" href="css/text.css">
		
		<title><%= pageTitle %></title>
EOF
		cat > joint.ejs << EOF			
	</head>
	<body>
EOF

		cat > footer.ejs << EOF
			
		<footer>
			<!-- Footer content -->

		</footer>

		<!-- Bootstrap 5.2 -->
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>
	</body>
</html>
EOF

	# Connect-Flash EJS
		if [ $useFlashSwal = "y" ] ; then
			cat > connect-flash-swal.ejs << EOF
<!-- Passing to SweetAlert2 -->
<% if (flashSwal[0]) { %>
<input type="hidden" name="swalType" id="swalType" value="<%= flashSwal[0].type %>">
<input type="hidden" name="swalTitle" id="swalTitle" value="<%= flashSwal[0].title %>">
<input type="hidden" name="swalMessage" id="swalMessage" value="<%= flashSwal[0].message %>">
<input type="hidden" name="swalDetails" id="swalDetails" value="<%= flashSwal[0].details %>">
<input type="hidden" name="swalFooter" id="swalFooter" value="<%= flashSwal[0].footer %>">	
<% } %>
EOF
		fi

		cd ../ # current path: views/

		cat > index.ejs << EOF
<%- include('./partials/head.ejs') %>
<!-- Extra head contents (eg. meta, link, style, or script) -->

<%- include('./partials/joint.ejs') %>
<!-- Body contents -->
		<header>
			<!-- Header content -->

		</header>

		<main>
			<!-- Main content -->

		</main>

<%- include('./partials/footer.ejs') %>
EOF

		if [ $useFlashSwal = "y" ] ; then
			sed -i "/<\/header>/a \
<%- include('./partials/connect-flash-swal.ejs') %>" index.ejs
		fi

		cd ../ # current path: /

		if [ $useFlashSwal = "y" ] ; then
			sed -i "/\/\/ End Response local variable list/i \
		res.locals.flashSwal = req.flash('flashSwal')" app.js

			sed -i "/<\!-- Internal CSS -->/a \
	<link rel=\"stylesheet\" href=\"css/connect-flash.css\">" views/partials/head.ejs

			cat > public/js/swals.js << EOF
function flashSwal() {
	try {
		const swalType=document.querySelector('input#swalType').value
		const swalTitle=document.querySelector('input#swalTitle').value
		const swalMessage=document.querySelector('input#swalMessage').value
		const swalDetails=document.querySelector('input#swalDetails').value
		const swalFooter=document.querySelector('input#swalFooter').value
		swal.fire({
			icon: swalType,
			title: swalTitle,
			html: swalDetails ? swalMessage + '<hr/><i>' + swalDetails + '</i>' : swalMessage,
			footer: swalFooter,
			timer: 30000,
			timerProgressBar: true,
		})
	} catch (error) {
		// pass
	}
}
EOF

			sed -i '/<\/head>/i \
		<script src="/js/swals.js"></script>' views/partials/joint.ejs

			sed -i 's/<body>/<body onload="flashSwal()">/g' views/partials/joint.ejs
		fi
		
		cat >> .prettierignore << EOF

# EJS files
*.ejs

EOF

	fi	
}

# Welcome Homepage
initWelcomeHomepage() {
	echo ""
	read -p "Create welcome homepage? (y/n): " createHomepage
	if [ $createHomepage = "y" ] ; then

		# favicon
		cd public/images
		wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/favicon.png

		cd ../.. # current path: /

		# CSS
		cat > public/css/main.css << EOF
@import url('https://fonts.googleapis.com/css2?family=Sofia+Sans&display=swap');

:root {
	--background-default: #c2e5f08c;
	--background-success: #0051808c;
	--background-warning: #ffae008f;
	--background-error: #e70f0fa4;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Sofia Sans', sans-serif;
}

body {
}

a,
a:link {
	text-decoration: none;
}

.welcome-box {
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
	margin: 25vh auto;
	padding: 3em;
	border: 2px #333 solid;
	border-radius: 7px;
}

EOF
		
		cat > routes/homeRoutes.js << EOF
const routes = require('express').Router()
const homeController = require('../controllers/homeController')

routes.get('/', homeController.getHome)

module.exports = routes
EOF

		sed -i "/\/\/ Routes/a \
const homeRoutes = require('./routes/homeRoutes')\n\n\
app.use(homeRoutes)" app.js

		# EJS & Form Validator
		if [ $useEJS = "y" ] ; then
			echo ""
			read -p "Use client-side Form Validator? (y/n): " useFormValidator

			cat > controllers/homeController.js << EOF
exports.getHome = (req, res) => {
	return res.render('index', {
		pageTitle: '$appName - Home',
	})
}

EOF

			if [ $useFlashSwal = "y" ] ; then
				echo ""
				echo "Creating controller file..."				
				cat >> controllers/homeController.js << EOF
exports.postHomeSwal = (req, res) => {
	req.flash('flashSwal', {
		type: 'success',
		title: 'Setup Completed',
		message: 'Connect-Flash-Swal ready',
		details: 'Connect-Flash and SweetAlert2 setup successful.',
		footer: '',
	})
	return res.redirect('/')
}

EOF
				echo "Updating route file..."
				sed -i "/module.exports = routes/i \
routes.post('\/flashswal', homeController.postHomeSwal)\n" routes/homeRoutes.js
			fi

			echo "Updating view file..."
			sed -i '/<\!-- Main content -->/a \
			<div class="container">\
				<div class="welcome-box">\
					<h1><b>WELCOME HOMEPAGE</b></h1>\
					<h3><b>Environment initialization successful.</b></h3>\n\
					<hr>\
					<!-- form-validation here -->\
					<hr>\
					<h5>You are ready to roll</h5>\
					<p>\
						<i><small>Generated by: feinz (<a href="mailto:feineirz@live.com">feineirz@live.com</a>)</small></i>\
					</p>\
				</div>\
			</div>' views/index.ejs

		# Form validation
			if [ useFormValidator ] ; then
				echo "Applying form validator..."
				cd public/js
				wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/formValidator.js
				wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/validationRules.js
				cd ../..

				cd public/css			
				wget https://raw.githubusercontent.com/feineirz/initenv.sh/master/assests/form-validator.css
				cd ../..

				sed -i '/<\!-- form-validation here -->/a \
		<form class="fv" action="\/flashswal" method="post">\
			<div class="title"><h3>Test Form-Validator<\/h3><\/div>\
			<hr>\
			<p><i>Please fill the form to test if Form-Validator works.<\/i><\/p>\
			<div class="form-floating mb-3">\
				<input \
					type="text" \
					class="form-control" \
					name="username" \
					id="username" \
					data-validation-rule="example"> \
				<label for="username">Username<\/label>\
			<\/div>\n\
			<div class="form-floating mb-3">\
				<input \
					type="password" \
					class="form-control" \
					name="password" \
					id="password" \
					data-validation-rule="example" \
					data-validation-matching="confirm_password"> \
				<label for="password">Password<\/label>\
			<\/div>\n\
			<div class="form-floating mb-3">\
				<input \
					type="password" \
					class="form-control" \
					name="confirm_password" \
					id="confirm_password" \
					data-validation-rule="example" \
					data-validation-matching="password"> \
				<label for="confirm_password">Confirm Password<\/label>\
			<\/div>\n\
			<div class="form-floating mb-3">\
				<input \
					type="email" \
					class="form-control" \
					name="email" \
					id="email"> \
				<label for="email">Email<\/label> \
			<\/div>\n\
			<div class="button-group">\
				<button class="btn btn-primary validation-submit-entry" type="submit">Send<\/button>\
			<\/div>\
		<\/form>' views/index.ejs

				sed -i "/<%- include('.\/partials\/joint.ejs') %>/i \
		<link rel=\"stylesheet\" href=\"css/form-validator.css\">" views/index.ejs

				sed -i "/<%- include('.\/partials\/footer.ejs') %>/i \
		<script type=\"module\" src=\"js/formValidator.js\"></script>" views/index.ejs
			fi

		else
			cat > controllers/homeController.js << EOF
exports.getHome = (req, res) => {
	const html = \`
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		<!-- For Bootstrap 5 -->
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

		<!-- Sweetalert2 -->
		<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

		<!-- Favicon -->
		<link rel="shortcut icon" href="images/favicon.png" type="image/x-icon">

		<!-- Internal CSS -->
		<link rel="stylesheet" href="css/main.css">
		
		<title>$appName - Home</title>	
	</head>
	<body>
		<header></header>

		<main>
			<div class="container">
				<div class="welcome-box">
					<h1><b>WELCOME HOMEPAGE</b></h1>
					<h3><b>Environment initialization successful.</b></h3>
					<hr/>
					<h5>You are ready to roll</h5>
					<p>
						<!-- prettier-ignore -->
						<i><small>Generated by: feinz (<a href="mailto:feineirz@live.com">feineirz@live.com</a>)</small></i>
					</p>
				</div>
			</div>
		</main>	

		<footer></footer>

		<!-- For Bootstrap -->
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

	</body>
</html> \`
	return res.send(html)
}
EOF
		fi
	fi
}

# Initialize project settings
initProjectSettings() {
	echo ""
	echo "== Initialize Project Settings =="
	read -p "Press any key to Initialize application" temp
	echo ""

	npm init

	sed -i '/"scripts": {/a \
	"dev": "nodemon app.js",\
	"start": "node app.js", ' package.json	
}

# Update local GIT
updateGit() {
	git add *
	git add .gitignore
	if [ $usePrettier = "y" ] ; then
		git add .prettierrc .prettierignore
	fi

	git commit -m "Initialize successful."

	if [ $useGithub = "y" ] ; then
		git push origin $branchName
	fi
}

# Finish Script
finishScript() {
	echo ""
	read -p "Running VSCode after initialize? (y/n): " runCode

	echo ""
	read -p "Running applicaton in developer mode after initialize? (y/n): " runDev

	echo ""
	echo "Environment initialization successful."
	echo ""
	echo "========================================================"

	if [ $runCode = "y" ] ; then
		code .
	fi

	if [ $runDev = "y" ] ; then
		npm run dev
	fi	
}

######################## End Functions ########################


########################## Invoke ##########################
#//////////////////////#
welcome
#//////////////////////#
initGitEnv
exit
#//////////////////////#
initProjectStructure
#//////////////////////#
installCommon
#//////////////////////#
installExpress
#//////////////////////#
initPrettier
#//////////////////////#
initSession
#//////////////////////#
pickMainStack
#//////////////////////#
initMainStack
#//////////////////////#
initFlashSwal
#//////////////////////#
initMulter
#//////////////////////#
initEJS
#//////////////////////#
initWelcomeHomepage
#//////////////////////#
# place app at last of init phase
sed -i "/\/\/ End Initialize/i \
const app = express()" app.js
#//////////////////////#
initProjectSettings
#//////////////////////#
updateGit
#//////////////////////#
finishScript
#//////////////////////#

######################## End Invoke ########################






