conda activate demo-har
cd ~/Projects/demos/opendr_internal/projects/perception/activity_recognition/demos/online_recognition
PYTHONPATH=/home/bleporowski/Projects/demos/opendr_internal/src python demo.py --ip=0.0.0.0 --port=2607 --device=cuda --algorithm cox3d --model m
