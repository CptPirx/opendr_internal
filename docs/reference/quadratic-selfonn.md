## quadraticselfonn module

The *quadraticselfonn* module contains the *QuadraticSelfOnnLearner* class, which inherits from the abstract class *Learner*.

### Class QuadraticSelfOnnLearner

Bases: `engine.learners.Learner`

The *QuadraticSelfOnnLearner* class is a wrapper of a Quadratic Self-ONN[[1]](#qselfonn-arxiv) implementation.
It is designed for limited-vocabulary speech command recognition tasks.


The [QuadraticSelfOnnLearner](#src.perception.speech_recognition.quadraticselfonn_learner.py) class has the following public methods:

#### `QuadraticSelfOnnLearner` constructor

```python
QuadraticSelfOnnLearner(self,
                        lr,
                        iters,
                        batch_size,
                        optimizer,
                        checkpoint_after_iter,
                        checkpoint_load_iter,
                        temp_path,
                        device,
                        expansion_order,
                        output_classes_n,
                        momentum,
                        preprocess_to_mfcc,
                        sample_rate
                        )
```

Constructor parameters:

- **lr**: *float, default=0.01*  
  Specifies the learning rate to be used during training.
- **iters**: *int, default=30*  
  Specifies the number of epochs the training should run for.
- **batch_size**: *int, default=64*  
  Specifies number of images to be bundled up in a batch during training.  
  This heavily affects memory usage, adjust according to your system.
  Should always be equal to or higher than the number of used CUDA devices.
- **optimizer**: *{'sgd', 'adam'}, default='sgd'*  
  Specifies the optimizer to be used. Currently, only SGD and Adam are supported.
- **checkpoint_after_iter**: *int, default=0*  
  Specifies per how many training iterations a checkpoint should be saved. If set to 0 no checkpoints will be saved.
  Saves the models to the `temp_path` as "QuadraticSelfOnn-\<epoch\>.pth"
- **checkpoint_load_iter**: *int, default=0*   
  Specifies a checkpoint to load based on the number of iterations before fitting.
  If set to 0 no checkpoint will be loaded.
- **temp_path**: *str, default='temp'*  
  Specifies the path to the directory where the checkpoints will be saved.
- **device**: *{'cpu', 'cuda'}, default='cuda'*  
  Specifies the device to be used.
- **expansion_order**: *int, default='3'*  
  Specifies the Taylor series expansion order for the network.
  See the [paper](#qselfonn-arxiv) for further information and visualization.
- **output_classes_n**: *int, default=20*  
  Specifies the number of output classes the samples can be categorized to.
- **momentum**: *float, default=0.9*  
  Specifies the momentum for the SGD optimizer if it is selected.
- **preprocess_to_mfcc**: *bool, default=True*  
  Specifies whether the learner should transform the input to a MFCC. If the input is already converted to a 2D signal, turn this off.
  Expects a 1D signal if set to true.
- **sample_rate**: *int, default=16000*  
  Specifies the assumed sampling rate for the input signals used in the MFCC conversion.
  Does nothing if *preprocess_to_mfcc* is set to false.

#### `QuadraticSelfOnnLearner.fit`

```python
QuadraticSelfOnnLearner.fit(self,
                            dataset,
                            val_dataset,
                            logging_path,
                            silent,
                            verbose)
```

This method is used for training the algorithm on a train dataset and validating on a val dataset.
Returns a dictionary containing stats regarding the last evaluation ran.

Parameters:

- **dataset**: *DatasetIterator*  
  Object that holds the training dataset. Will be used by a PyTorch `DataLoader`.
  Can be anything that can be passed to `DataLoader` as a dataset, but a safe way is to inherit it from `DatasetIterator`.
- **val_dataset**: *DatasetIterator, default=None*  
  Object that holds the validation dataset. Same rules apply as above.
- **logging_path**: *str, default=''*  
  Path to save log files. If set to None or '', logging is disabled.
- **silent**: *bool, default=True*  
  If set to True, disables all printing of training progress reports and other information to STDOUT.
- **verbose**: *bool, default=True*  
  If set to True, enables additional log messages regarding model training.

#### `QuadraticSelfOnnLearner.eval`

```python
QuadraticSelfOnnLearner.eval(self, dataset)
```

This method is used to evaluate a trained model on an evaluation dataset.
Returns a dictionary containing stats regarding evaluation.  

Parameters:

- **dataset**: *DatasetIterator*  
  Object that holds the training dataset.
  Will be used by a PyTorch `DataLoader`.
  Can be anything that can be passed to Dataloader as a dataset, but a safe way is to inherit it from `DatasetIterator`.

#### `QuadraticSelfOnnLearner.infer`

```python
QuadraticSelfOnnLearner.infer(self, batch)
```

This method is used to classify signals. Can be used to infer a single utterance, or a batch of signals.

Parameters:

- **batch**: *Timeseries* or *List*[*Timeseries*]   
  Either a `Timeseries` or a list of `Timeseries`.

#### `QuadraticSelfOnnLearner.save`

```python
QuadraticSelfOnnLearner.save(self, path)
```

This method saves the model in the directory provided by `path`.

Parameters:

- **path**: *str*  
  Path to the directory where the model should be saved.
  Does not need to exist before the function call.

#### `QuadraticSelfOnnLearner.load`

```python
QuadraticSelfOnnLearner.load(self, path)
```

This method loads the model from the directory provided by `path`.
In practice the same path as provided to `save` beforehand.

Parameters:

- **path**: *str*  
  Path to the model directory to be loaded.

#### `QuadraticSelfOnnLearner.download_pretrained`

```python
QuadraticSelfOnnLearner.download_pretrained(self, path)
```

This method downloads a pretrained model from the OpenDR FTP server.
The pretrained model was trained on 20 classes of the GSC dataset in alphabetical classification order.
A new directory will be created to the directory specified by path called "QuadraticSelfOnn", where the model will be saved.

Parameters:

- **path**: *str, default="."*   
  Path to the parent directory where the model should be downloaded.

#### Examples

* **Training example using randomized data in place of recorded samples.**
```python
import numpy as np
import os

from opendr.engine.datasets import DatasetIterator
from opendr.perception.speech_recognition.quadraticselfonn.quadraticselfonn_learner import QuadraticSelfOnnLearner

class RandomDataset(DatasetIterator):
    def __init__(self):
        super().__init__()
        
    def __len__(self):
        return 64

    def __getitem__(self, item):
        return np.random.rand(16000), np.random.choice(10)

learner = QuadraticSelfOnnLearner(output_classes_n=10, iters=10, expansion_order=3)
training_dataset = RandomDataset()
validation_dataset = RandomDataset()

results = learner.fit(dataset=training_dataset, val_dataset=validation_dataset)
# Print the validation accuracy of the last epoch and save the model to a file
print(results[10]["validation_results"]["test_accuracy"])
learner.save(os.path.join(".", "example", "directory", "path", "model"))
 ```

* **Load an existing model and infer a sample from an existing file.**
```python
import librosa
import numpy as np
import os

from opendr.engine.data import Timeseries
from opendr.perception.speech_recognition.quadraticselfonn.quadraticselfonn_learner import QuadraticSelfOnnLearner

learner = QuadraticSelfOnnLearner(output_classes_n=10)
learner.load(os.path.join(".", "example", "directory", "path", "model"))

# Assuming you have recorded your own voice sample in command.wav in the current directory
signal, sampling_rate = librosa.load("command.wav", sr=learner.sample_rate)
signal = np.expand_dims(signal, axis=0)
timeseries = Timeseries(signal)
result = learner.infer(timeseries)
print(result)
```

#### References

<a name="qselfonn-arxiv" href="https://arxiv.org/abs/2011.11436">[1]</a>
Speech Command Recognition in Computationally Constrained Environments with a Quadratic Self-organized Operational
Layer,
[arXiv](https://arxiv.org/abs/2011.11436).  
