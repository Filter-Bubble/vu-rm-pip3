import wrapper.pipeline as pipeline
import wrapper.dag as dag
import pytest

single_word='tests/data/single_word.txt'
cfg='example/pipeline.yml'


def test_pipeline_creation():
    p = pipeline.create_pipeline(cfg)
    assert p.nb_modules() == 13  
    scheduled = p.topological_sort()
    assert len(scheduled) == 13


def test_create_pipeline_with_in_layers_and_goals():
    goal_layers = ['opinions','entities']
    in_layers=['text','terms','deps','constituents'] 
    p = pipeline.create_pipeline(cfg)
    assert p.nb_modules() == 13
    p.filter_layers(goal_layers)    
    assert p.nb_modules() == 4
    p.filter_input_layers(in_layers, [])    
    assert p.nb_modules() == 2
    
    p = pipeline.create_pipeline(cfg, in_layers=in_layers, goal_layers=goal_layers)
    assert p.nb_modules() == 2
    assert 'opinion-miner' in p.graph.get_keys()
    assert 'ixa-pipe-nerc' in p.graph.get_keys()


def test_goals():
    p = pipeline.create_pipeline(cfg, goal_layers=['text'])
    assert p.nb_modules() == 1  
    p = pipeline.create_pipeline(cfg, goal_layers=['deps'])
    assert p.nb_modules() == 2  
    p = pipeline.create_pipeline(cfg, goal_layers=['terms'])
    assert p.nb_modules() == 4  
    p = pipeline.create_pipeline(cfg, goal_layers=['srl'])
    assert p.nb_modules() == 8  


def test_create_pipeline_with_in_layers_and_modules():
    goal_modules=['vua-wsd']
    in_layers=['text','terms','deps','constituents'] 
    p = pipeline.create_pipeline(cfg, in_layers=in_layers, goal_modules=goal_modules)
    assert p.nb_modules() == 1
    p = pipeline.create_pipeline(cfg, in_layers=['text','terms'], goal_modules=goal_modules)
    assert p.nb_modules() == 1
    p = pipeline.create_pipeline(cfg, in_layers=['text','terms'], goal_modules=['vua-alpino'])
    assert p.nb_modules() == 1
    p = pipeline.create_pipeline(cfg, in_layers=['text','deps'], goal_modules=['vua-wsd'])
    assert p.nb_modules() == 1
    p = pipeline.create_pipeline(cfg, in_layers=['text','deps'], goal_modules=['vua-ontotagging'])
    assert 'vua-wsd' in p.graph.get_keys()
    assert p.nb_modules() == 2
    p = pipeline.create_pipeline(cfg, in_layers=['text','deps'], goal_modules=['vua-wsd','vua-ontotagging'])
    assert p.nb_modules() == 2
    p = pipeline.create_pipeline(cfg, in_layers=['text','terms'], goal_modules=['vua-ontotagging'])
    assert p.nb_modules() == 1


def test_zero_pipeline():
    goal_layers = ['terms']
    p = pipeline.create_pipeline(cfg, in_layers=['text','terms','deps','constituents'], goal_layers=goal_layers)
    assert p.nb_modules() == 0
    scheduled = p.topological_sort()
    assert p.nb_modules() == 0


def test_pipeline_layers_already_there():
    goal_layers = ['text']
    p = pipeline.create_pipeline(cfg, in_layers=['text','terms','deps','constituents'], goal_layers=goal_layers)
    assert p.nb_modules() == 0
    scheduled = p.topological_sort()
    assert p.nb_modules() == 0


def test_goal_modules_after_goal_layers():
    goal_modules = ['opinion-miner']
    with pytest.raises(KeyError) as e:
        p = pipeline.create_pipeline(cfg, goal_layers=['entities', 'terms', 'text', 'deps','constituents'], goal_modules=goal_modules)


def test_loading_modules_with_non_default_options():
    modules = pipeline.load_modules(cfg, {'vua-alpino': '-t 0.2'})
    assert len(modules) == 13
    alpino_cmd = [ m.cmd for m in modules if m.id == 'vua-alpino' ]
    assert alpino_cmd[0] == "vua-alpino.sh -t 0.2" 


