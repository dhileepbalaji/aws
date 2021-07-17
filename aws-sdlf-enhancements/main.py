import json
import logging
from configparser import ConfigParser
import os
import subprocess


def cleanUpFiles(filenames):
    for file in filenames:
        try:
            os.remove(file)
        except FileNotFoundError as e:
            logger.debug(f'File not exists. {e}')
        except Exception as e:
            logger.error(f"Unhandled exception occured {e}")


def runBash(cmd):
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               universal_newlines=True)

    while True:
        line = process.stdout.readline()
        print(line)
        if line == '' and process.poll() != None:
            break
    return process.returncode


def generateTeamParameters(teamToDeploy: str, ):
    try:
        logger.info('Cleaning up generated files if exists')
        cleanUpFiles([devParamJsonFile, prodParamJsonFile, tagsJsonFile, metadataJsonFile])
        # location of team json file
        teamJsonLocation = f'teams/{teamToDeploy}.json'
        teamJson = open(teamJsonLocation, 'r')
        teamJsonData = json.load(teamJson)
        # Create parameter and tags  files and dump json in to it
        # Creates dev parameter json file
        devParamJson = open(devParamJsonFile, 'w')
        json.dump(teamJsonData['dev'], devParamJson)
        # Creates prod parameter json file
        prodParamJson = open(prodParamJsonFile, 'w')
        json.dump(teamJsonData['prod'], prodParamJson)
        # Creates tags json file
        tagsJson = open(tagsJsonFile, 'w')
        json.dump(teamJsonData['tags'], tagsJson)
        # Creates metadata json file
        metadataJson = open(metadataJsonFile, 'w')
        json.dump(teamJsonData['metadata'], metadataJson)
        logger.info('Successfully Generated the Tags and Parameters file. Running Deploy.sh ...')
    except (IOError, ValueError, EOFError) as e:
        logger.error(f'Unable to generate the Tags and Parameters file. {e}')
        exit(1)
    except Exception as e:
        logger.error(f'Unhandled Exception Occurred. {e}')
        exit(1)


# Logger Config
logger = logging.getLogger("GenerateDeployJson")
logger.propagate = False
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s  %(name)s  %(levelname)s: %(message)s')
consoleHandler = logging.StreamHandler()
# Set Log Level to INFO
consoleHandler.setLevel(logging.INFO)
consoleHandler.setFormatter(formatter)
logger.addHandler(consoleHandler)

# read deploy.config and get the team name to deploy the changes.
teamConfig = ConfigParser()
teamConfig.read('./deploy.config')
teamToDeploy = teamConfig.get('team', 'name').split(',')
if 'all' in teamToDeploy:
    os.chdir('./teams')
    teamToDeploy = [".".join(file.split(".")[:-1]) for file in os.listdir() if os.path.isfile(file)]
    os.chdir('../')

# declare filenames to be created
devParamJsonFile = './parameters-dev.json'
prodParamJsonFile = './parameters-prod.json'
tagsJsonFile = './tags.json'
metadataJsonFile = './metadata.json'

# loop through each team and deploy the code.
for team in teamToDeploy:
    # call to generateTeamParameters for generating the team's json files
    logger.info(f"Executing the deployment for {team}")
    generateTeamParameters(team)
    # run the deploy.sh
    runDeployScript = runBash('./deploy.sh')
    # exit the execution for other teams if any error encountered on deploy.sh
    if runDeployScript != 0:
        exit(1)

    logger.info(f'Completed execution for team : {team}')
